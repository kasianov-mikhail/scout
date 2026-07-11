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
@Suite("SyncableObject.plan")
struct SyncableObjectPlanTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Seeds a pending delivery per backend for a syncable record")
    func seedsDeliveries() throws {
        let event = EventObject.stub(name: "login", in: context)
        try context.save()

        try SyncableObject.plan(backends: [makeBackend(id: "cloud"), makeBackend(id: "server")], in: context)

        #expect(event.deliveries.count == 2)
        #expect(event.delivery(for: "cloud")?.isPending == true)
        #expect(event.delivery(for: "server")?.isPending == true)
    }

    @Test("Ignores local-only objects")
    func skipsLocalOnly() throws {
        let marker = context.insert(VersionMarker.self)
        marker.markerID = UUID()
        marker.name = VersionMarker.installName
        marker.date = Date()
        try context.save()

        try SyncableObject.plan(backends: [makeBackend(id: "cloud")], in: context)

        #expect(try context.fetchAll(SyncDelivery.self).isEmpty)
    }
}
