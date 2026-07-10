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
struct SyncableObjectCleanupTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Deletes synced events older than 7 days")
    func deletesSyncedOldEvent() throws {
        let old = Date(timeIntervalSinceNow: -8 * 86400)
        EventObject.stub(name: "old", date: old, synced: true, in: context)
        try context.save()

        try SyncableObject.cleanup(backends: [], in: context)

        #expect(try context.fetchAll(EventObject.self).isEmpty)
    }

    @Test("Deletes synced launches older than 7 days")
    func deletesSyncedOldLaunch() throws {
        let old = Date(timeIntervalSinceNow: -8 * 86400)
        LaunchObject.stub(date: old, synced: true, in: context)
        try context.save()

        try SyncableObject.cleanup(backends: [], in: context)

        #expect(try context.fetchAll(LaunchObject.self).isEmpty)
    }

    @Test("Keeps synced objects newer than 7 days")
    func keepsSyncedRecent() throws {
        let recent = Date(timeIntervalSinceNow: -6 * 86400)
        EventObject.stub(name: "recent", date: recent, synced: true, in: context)
        try context.save()

        try SyncableObject.cleanup(backends: [], in: context)

        #expect(try context.fetchAll(EventObject.self).count == 1)
    }

    @Test("Keeps a synced old launch still referenced by another record")
    func keepsReferencedLaunch() throws {
        let old = Date(timeIntervalSinceNow: -8 * 86400)
        let launch = LaunchObject.stub(date: old, synced: true, in: context)
        let session = SessionObject.stub(date: old, launch: launch, in: context)
        EventObject.stub(name: "child", session: session, in: context)
        try context.save()

        try SyncableObject.cleanup(backends: [], in: context)

        #expect(try context.fetchAll(LaunchObject.self).count == 1)
    }

    @Test("Keeps objects with outstanding work regardless of age")
    func keepsUnsynced() throws {
        // Done-ness is derived from delivery rows: cleanup only purges objects
        // whose configured backends are all settled, never ones still owing work.
        let old = Date(timeIntervalSinceNow: -8 * 86400)
        let event = EventObject.stub(name: "pending", date: old, in: context)
        event.seedDelivery(for: "cloud", in: context)
        try context.save()

        try SyncableObject.cleanup(backends: [makeBackend(id: "cloud")], in: context)

        #expect(try context.fetchAll(EventObject.self).count == 1)
    }
}
