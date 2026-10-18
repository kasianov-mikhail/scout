//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

@Suite("ScoutModel migrations")
struct MigrationTests {
    @Test("Every historical model version migrates to the current model")
    func historicalVersionsMigrate() throws {
        let momdURL = try #require(Bundle.module.url(forResource: "ScoutModel", withExtension: "momd"))
        let current = NSManagedObjectModel.scout

        let versions = try FileManager.default
            .contentsOfDirectory(at: momdURL, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "mom" }

        // A broken resource lookup would make the loop below pass vacuously;
        // the model ships at least three versions, so fewer means enumeration
        // silently failed.
        try #require(versions.count >= 3)

        for versionURL in versions {
            let old = try #require(NSManagedObjectModel(contentsOf: versionURL))
            guard old.entityVersionHashesByName != current.entityVersionHashesByName else {
                continue
            }

            let store = try TemporaryStore()
            defer { store.tearDown() }
            let storeURL = store.url

            let oldCoordinator = NSPersistentStoreCoordinator(managedObjectModel: old)
            let oldStore = try oldCoordinator.addPersistentStore(type: .sqlite, at: storeURL)
            try oldCoordinator.remove(oldStore)

            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: current)
            let options: [String: Any] = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true,
            ]

            do {
                let store = try coordinator.addPersistentStore(
                    ofType: NSSQLiteStoreType,
                    configurationName: nil,
                    at: storeURL,
                    options: options
                )
                let metadata = coordinator.metadata(for: store)
                #expect(current.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata))
                try coordinator.remove(store)
            } catch {
                Issue.record("Store created by \(versionURL.lastPathComponent) failed to migrate: \(error)")
            }
        }
    }

    @Test("A ScoutModel 4 store keeps its crashes and launches after migration")
    func version4DataSurvives() throws {
        let store = try TemporaryStore()
        defer { store.tearDown() }

        let momdURL = try #require(Bundle.module.url(forResource: "ScoutModel", withExtension: "momd"))
        let old = try #require(NSManagedObjectModel(contentsOf: momdURL.appendingPathComponent("ScoutModel 4.mom")))

        let launchID = UUID()
        let crashID = UUID()
        let date = Date(timeIntervalSince1970: 1_750_000_000)

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: old)
        let seeded = try coordinator.addPersistentStore(type: .sqlite, at: store.url)
        let seed = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        seed.persistentStoreCoordinator = coordinator

        try seed.performAndWait {
            let launch = seed.insert(LaunchEntry.self)
            launch.launchID = launchID
            launch.date = date

            let crash = seed.insert(CrashEntry.self)
            crash.crashID = crashID
            crash.name = "SIGSEGV"
            crash.reason = "Signal 11 received"
            crash.date = date

            try seed.save()
        }
        try coordinator.remove(seeded)

        let context = try store.container().newBackgroundContext()
        try context.performAndWait {
            let launch = try #require(try context.existing(LaunchEntry.self, key: "launchID", id: launchID))
            #expect(launch.processID == 0)

            let crash = try #require(try context.existing(CrashEntry.self, key: "crashID", id: crashID))
            #expect(crash.name == "SIGSEGV")
            #expect(crash.reason == "Signal 11 received")
            #expect(crash.source == nil)
            #expect(crash.windowStart == nil)
        }
    }

    @Test("A ScoutModel 11 store keeps the session of every child after migration")
    func version11SessionLinksSurvive() throws {
        let store = try TemporaryStore()
        defer { store.tearDown() }

        let momdURL = try #require(Bundle.module.url(forResource: "ScoutModel", withExtension: "momd"))
        let old = try #require(NSManagedObjectModel(contentsOf: momdURL.appendingPathComponent("ScoutModel 11.mom")))

        let sessionID = UUID()
        let date = Date(timeIntervalSince1970: 1_750_000_000)

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: old)
        let seeded = try coordinator.addPersistentStore(type: .sqlite, at: store.url)
        let seed = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        seed.persistentStoreCoordinator = coordinator

        try seed.performAndWait {
            let session = seed.insert(SessionEntry.self)
            session.sessionID = sessionID
            session.date = date

            let event = seed.insert(EventEntry.self)
            event.eventID = UUID()
            event.name = "purchase"
            event.level = "info"

            let screen = seed.insert(ScreenEntry.self)
            screen.screenID = UUID()
            screen.name = "Home"

            let condition = seed.insert(ConditionEntry.self)
            condition.conditionID = UUID()
            condition.kind = "thermal_state"

            let metrics = seed.insert(IntMetricsEntry.self)
            metrics.name = "requests"
            metrics.telemetry = "counter"
            metrics.value = 1

            let crash = seed.insert(CrashEntry.self)
            crash.crashID = UUID()
            crash.name = "SIGSEGV"

            let hang = seed.insert(HangEntry.self)
            hang.hangID = UUID()
            hang.name = "Hang"
            hang.duration = 2

            let resource = seed.insert(ResourceEntry.self)
            resource.resourceID = UUID()
            resource.name = "CPU"
            resource.kind = "cpu"

            let children: [SessionChildEntry] = [event, screen, condition, metrics, crash, hang, resource]
            for child in children {
                child.date = date
                child.session = session
            }

            try seed.save()
        }
        try coordinator.remove(seeded)

        let context = try store.container().newBackgroundContext()
        try context.performAndWait {
            let session = try #require(try context.existing(SessionEntry.self, key: "sessionID", id: sessionID))

            let entities = ["EventEntry", "ScreenEntry", "ConditionEntry", "IntMetricsEntry", "CrashEntry", "HangEntry", "ResourceEntry"]
            for entity in entities {
                let children = try context.fetch(NSFetchRequest<SessionChildEntry>(entityName: entity))
                #expect(children.count == 1, "\(entity) survives")
                #expect(children.allSatisfy { $0.session == session }, "\(entity) keeps its session")
            }

            #expect(session.children.count == entities.count)
        }
    }
}
