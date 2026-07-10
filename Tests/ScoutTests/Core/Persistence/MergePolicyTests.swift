//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

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

        let context = container.viewContext
        let eventID = UUID()

        let first = EventObject.stub(name: "first", in: context)
        first.eventID = eventID
        try context.save()

        let second = EventObject.stub(name: "second", in: context)
        second.eventID = eventID
        try context.save()

        let request = NSFetchRequest<EventObject>(entityName: "EventObject")
        let events = try context.fetch(request)
        #expect(events.count == 1)
    }
}
