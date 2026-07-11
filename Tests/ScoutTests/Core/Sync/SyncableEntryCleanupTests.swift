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
@Suite("SyncableEntry.cleanup")
struct SyncableEntryCleanupTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Deletes synced events older than 7 days")
    func deletesSyncedOldEvent() throws {
        let old = Date(timeIntervalSinceNow: -8 * 86400)
        EventEntry.stub(name: "old", date: old, synced: true, in: context)
        try context.save()

        try SyncableEntry.cleanup(backends: [], in: context)

        #expect(try context.fetchAll(EventEntry.self).isEmpty)
    }

    @Test("Deletes synced launches older than 7 days")
    func deletesSyncedOldLaunch() throws {
        let old = Date(timeIntervalSinceNow: -8 * 86400)
        LaunchEntry.stub(date: old, synced: true, in: context)
        try context.save()

        try SyncableEntry.cleanup(backends: [], in: context)

        #expect(try context.fetchAll(LaunchEntry.self).isEmpty)
    }

    @Test("Keeps synced objects newer than 7 days")
    func keepsSyncedRecent() throws {
        let recent = Date(timeIntervalSinceNow: -6 * 86400)
        EventEntry.stub(name: "recent", date: recent, synced: true, in: context)
        try context.save()

        try SyncableEntry.cleanup(backends: [], in: context)

        #expect(try context.fetchAll(EventEntry.self).count == 1)
    }

    @Test("Keeps a synced old launch still referenced by another record")
    func keepsReferencedLaunch() throws {
        let old = Date(timeIntervalSinceNow: -8 * 86400)
        let launch = LaunchEntry.stub(date: old, synced: true, in: context)
        let session = SessionEntry.stub(date: old, launch: launch, in: context)
        EventEntry.stub(name: "child", session: session, in: context)
        try context.save()

        try SyncableEntry.cleanup(backends: [], in: context)

        #expect(try context.fetchAll(LaunchEntry.self).count == 1)
    }

    @Test("Keeps objects with outstanding work regardless of age")
    func keepsUnsynced() throws {
        // Done-ness is derived from delivery rows: cleanup only purges objects
        // whose configured backends are all settled, never ones still owing work.
        let old = Date(timeIntervalSinceNow: -8 * 86400)
        let event = EventEntry.stub(name: "pending", date: old, in: context)
        event.seedDelivery(for: "cloud", in: context)
        try context.save()

        try SyncableEntry.cleanup(backends: [makeBackend(id: "cloud")], in: context)

        #expect(try context.fetchAll(EventEntry.self).count == 1)
    }
}
