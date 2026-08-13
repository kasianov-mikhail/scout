//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout
@testable import Support

@MainActor
@Suite("Merge policy")
struct MergePolicyTests {
    /// Uniqueness constraints are only enforced by the SQLite store, so this
    /// builds a real file-backed store (an in-memory store would silently allow
    /// the duplicate) to prove the merge policy dedupes a colliding insert
    /// instead of throwing.
    ///
    @Test("A duplicate insert on the same natural key dedupes instead of throwing")
    func duplicateInsertDedupes() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let container = try makeContainer(in: directory)

        // The main-queue viewContext is off-limits here: Swift Testing runs on a
        // background thread, and mutating it there races the main run loop's own
        // change processing — an intermittent CI crash in
        // -[NSManagedObjectContext _processPendingUpdates:]. A private-queue
        // context confines every mutation to performAndWait instead.
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.scout

        let eventID = UUID()
        let events = try context.performAndWait {
            let first = EventEntry.stub(name: "first", in: context)
            first.eventID = eventID
            try context.save()

            let second = EventEntry.stub(name: "second", in: context)
            second.eventID = eventID
            try context.save()

            let request = NSFetchRequest<EventEntry>(entityName: "EventEntry")
            return try context.fetch(request)
        }
        #expect(events.count == 1)
    }

    /// Attaching a metrics row to a session enlists that session in the save's
    /// optimistic locking, so writes racing an update of the same session fail
    /// with "Could not merge changes" on the default policy — the burst of
    /// "Failed to save metrics" the telemetry handler used to print.
    ///
    @Test("Concurrent writes touching one session merge instead of failing")
    func concurrentSessionWritesMerge() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let container = try makeContainer(in: directory)

        let identity = Identity.stub.snapshot
        try await container.performBackgroundTask { @Sendable context in
            _ = try context.linkedSession(identity, date: Date())
            try context.save()
        }

        let failures = Protected<[String]>([])

        await withTaskGroup(of: Void.self) { group in
            for value in 1...20 {
                group.addTask {
                    do {
                        try await container.performBackgroundTask { context in
                            context.mergePolicy = NSMergePolicy.scout
                            try saveMetrics(
                                "counter",
                                date: Date(),
                                category: Telemetry.Export.counter.rawValue,
                                value: value,
                                identity: identity,
                                context
                            )
                        }
                    } catch {
                        failures.mutate { $0.append(error.localizedDescription) }
                    }
                }
            }
            for _ in 1...10 {
                group.addTask {
                    do {
                        try await container.performBackgroundTask { context in
                            context.mergePolicy = NSMergePolicy.scout

                            let session = try context.existing(
                                SessionEntry.self, key: "sessionID", id: identity.session)
                            session?.endDate = Date()
                            try context.save()
                        }
                    } catch {
                        failures.mutate { $0.append(error.localizedDescription) }
                    }
                }
            }
        }

        #expect(failures.current.count == 0)

        let context = container.newBackgroundContext()
        try context.performAndWait {
            let request = NSFetchRequest<SessionEntry>(entityName: "SessionEntry")
            let sessions = try context.fetch(request)
            #expect(sessions.first?.metrics.count == 20)
        }
    }

    /// The fetch-then-insert in `linkedSession` races across background
    /// contexts (telemetry, logs, incidents all write concurrently), so this
    /// hammers it from many tasks and expects the uniqueness constraints to
    /// collapse the colliding inserts to a single row per lifecycle entity.
    ///
    @Test("Racing linkedSession writes collapse to one row per lifecycle entity")
    func concurrentLinkedSessionDedupes() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let container = try makeContainer(in: directory)

        let identity = Identity.stub.snapshot
        let failures = Protected<[String]>([])

        await withTaskGroup(of: Void.self) { group in
            for _ in 1...20 {
                group.addTask {
                    do {
                        try await container.performBackgroundTask { context in
                            context.mergePolicy = NSMergePolicy.scout
                            _ = try context.linkedSession(identity, date: Date())
                            try context.save()
                        }
                    } catch {
                        failures.mutate { $0.append(error.localizedDescription) }
                    }
                }
            }
        }

        #expect(failures.current.count == 0)

        let context = container.newBackgroundContext()
        try context.performAndWait {
            for entity in ["DeviceEntry", "InstallEntry", "LaunchEntry", "SessionEntry"] {
                let request = NSFetchRequest<NSManagedObject>(entityName: entity)
                let count = try context.count(for: request)
                #expect(count == 1, "\(entity) deduplicated")
            }
        }
    }

    /// The worst interleaving behind the empty-overwrites-filled bug.
    ///
    /// A bare `linkedSession` row and a filled session for the same ID are
    /// both in flight before either saves. The constraint merge must keep the
    /// filled attributes instead of blanking them with the bare insert's nils.
    ///
    @Test("A bare duplicate insert keeps the filled session fields")
    func bareDuplicateKeepsFilledFields() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let container = try makeContainer(in: directory)

        let identity = Identity.stub.snapshot

        let filler = container.newBackgroundContext()
        filler.mergePolicy = NSMergePolicy.scout
        let racer = container.newBackgroundContext()
        racer.mergePolicy = NSMergePolicy.scout

        try filler.performAndWait {
            let session = try filler.linkedSession(identity, date: Date())
            session.appVersion = "1.2.3"
            session.osVersion = "26.0"
        }
        try racer.performAndWait {
            _ = try racer.linkedSession(identity, date: Date())
        }
        try filler.performAndWait {
            try filler.save()
        }
        try racer.performAndWait {
            try racer.save()
        }

        let context = container.newBackgroundContext()
        try context.performAndWait {
            let request = NSFetchRequest<SessionEntry>(entityName: "SessionEntry")
            let sessions = try context.fetch(request)
            #expect(sessions.count == 1)
            #expect(sessions.first?.appVersion == "1.2.3")
            #expect(sessions.first?.osVersion == "26.0")
        }
    }

    /// Uniqueness constraints and row versioning are only enforced by the SQLite
    /// store, so every case here needs a real file-backed store — an in-memory
    /// one silently allows the duplicate and never conflicts.
    ///
    private func makeContainer(in directory: URL) throws -> NSPersistentContainer {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let container = NSPersistentContainer(named: "ScoutModel")
        container.persistentStoreDescriptions = [
            NSPersistentStoreDescription(url: directory.appendingPathComponent("ScoutModel.sqlite"))
        ]
        try container.loadStore()

        return container
    }
}
