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
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let container = NSPersistentContainer(named: "ScoutModel")
        container.persistentStoreDescriptions = [
            NSPersistentStoreDescription(url: directory.appendingPathComponent("ScoutModel.sqlite"))
        ]
        try container.loadStore()

        // The main-queue viewContext is off-limits here: Swift Testing runs on a
        // background thread, and mutating it there races the main run loop's own
        // change processing — an intermittent CI crash in
        // -[NSManagedObjectContext _processPendingUpdates:]. A private-queue
        // context confines every mutation to performAndWait instead.
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

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
}
