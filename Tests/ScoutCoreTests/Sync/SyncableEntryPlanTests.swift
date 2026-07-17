//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import ScoutCore
@testable import ScoutTestSupport

@MainActor
@Suite("SyncableEntry.plan")
struct SyncableEntryPlanTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Seeds a pending delivery per backend for a syncable record")
    func seedsDeliveries() throws {
        let event = EventEntry.stub(name: "login", in: context)
        try context.save()

        try SyncableEntry.plan(backends: [makeBackend(id: "cloud"), makeBackend(id: "server")], in: context)

        #expect(event.deliveries.count == 2)
        #expect(event.delivery(for: "cloud")?.isPending == true)
        #expect(event.delivery(for: "server")?.isPending == true)
    }

    @Test("Ignores local-only objects")
    func skipsLocalOnly() throws {
        let marker = context.insert(MarkerEntry.self)
        marker.markerID = UUID()
        marker.name = MarkerEntry.installName
        marker.date = Date()
        try context.save()

        try SyncableEntry.plan(backends: [makeBackend(id: "cloud")], in: context)

        #expect(try context.fetchAll(DeliveryEntry.self).isEmpty)
    }
}
