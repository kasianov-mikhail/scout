//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

@MainActor
@Suite("SyncableObject.cleanup")
struct CleanupTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Deletes synced objects older than 7 days")
    func deletesSyncedOld() throws {
        let old = Date(timeIntervalSinceNow: -8 * 86400)
        EventObject.stub(name: "old", date: old, synced: true, in: context)
        try context.save()

        try SyncableObject.cleanup(in: context)

        let request = NSFetchRequest<EventObject>(entityName: "EventObject")
        #expect(try context.fetch(request).isEmpty)
    }

    @Test("Keeps synced objects newer than 7 days")
    func keepsSyncedRecent() throws {
        let recent = Date(timeIntervalSinceNow: -6 * 86400)
        EventObject.stub(name: "recent", date: recent, synced: true, in: context)
        try context.save()

        try SyncableObject.cleanup(in: context)

        let request = NSFetchRequest<EventObject>(entityName: "EventObject")
        #expect(try context.fetch(request).count == 1)
    }

    @Test("Deletes objects that exceeded sync attempt limit")
    func deletesStale() throws {
        let event = EventObject.stub(name: "stale", synced: false, in: context)
        event.syncAttempts = 11
        try context.save()

        try SyncableObject.cleanup(in: context)

        let request = NSFetchRequest<EventObject>(entityName: "EventObject")
        #expect(try context.fetch(request).isEmpty)
    }

    @Test("Keeps unsynced objects under attempt limit")
    func keepsUnsynced() throws {
        let event = EventObject.stub(name: "pending", synced: false, in: context)
        event.syncAttempts = 5
        try context.save()

        try SyncableObject.cleanup(in: context)

        let request = NSFetchRequest<EventObject>(entityName: "EventObject")
        #expect(try context.fetch(request).count == 1)
    }
}
