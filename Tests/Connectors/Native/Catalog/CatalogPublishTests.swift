//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Foundation
import ScoutDB
import ScoutDBTesting
import Testing

@testable import NativeConnector

@Suite("Catalog publishing")
struct CatalogPublishTests {
    let probe = ConcurrencyProbe(InMemoryDatabase())
    let registry: SchemaRegistry
    let store: EntityStore

    init() {
        registry = SchemaRegistry(database: probe)
        store = EntityStore(database: probe, registry: registry)
    }

    @Test("Every declared entity ends up published as declared")
    func publishesEveryEntity() async throws {
        await CatalogEntry.publishAll(into: store, registry: registry)

        for entry in CatalogEntry.entries {
            let published = try await registry.schema(for: entry.entity)
            #expect(entry.matches(published), "\(entry.entity) was published with a different shape")
        }
    }

    @Test("Entities reconcile together rather than one after another")
    func publishesConcurrently() async {
        await CatalogEntry.publishAll(into: store, registry: registry)

        #expect(await probe.peak > 1, "the catalog was published one entity at a time")
    }
}

/// Forwards to an in-memory database while recording how many requests were
/// ever in flight at once.
final class ConcurrencyProbe: CloudDatabase, @unchecked Sendable {
    private let database: InMemoryDatabase
    private let flight = Flight()

    init(_ database: InMemoryDatabase) {
        self.database = database
    }

    var peak: Int {
        get async { await flight.peak }
    }

    func records(matching query: CKQuery, resultsLimit: Int) async throws -> QueryPage {
        try await tracked { try await database.records(matching: query, resultsLimit: resultsLimit) }
    }

    func records(continuingMatchFrom cursor: QueryCursor, resultsLimit: Int) async throws -> QueryPage {
        try await tracked { try await database.records(continuingMatchFrom: cursor, resultsLimit: resultsLimit) }
    }

    func modifyRecords(saving: [CKRecord], deleting: [CKRecord.ID]) async throws {
        try await tracked { try await database.modifyRecords(saving: saving, deleting: deleting) }
    }

    func saveIfUnchanged(_ records: [CKRecord]) async throws -> [(CKRecord.ID, Result<CKRecord, any Error>)] {
        try await tracked { try await database.saveIfUnchanged(records) }
    }

    func fetchRecord(id: CKRecord.ID) async throws -> CKRecord? {
        try await tracked { try await database.fetchRecord(id: id) }
    }

    func fetchRecords(ids: [CKRecord.ID]) async throws -> [CKRecord] {
        try await tracked { try await database.fetchRecords(ids: ids) }
    }

    // The sleep widens the window a sequential caller would never overlap in,
    // so the peak separates "started together" from "started in turn".
    private func tracked<T>(_ request: () async throws -> T) async throws -> T {
        await flight.enter()
        defer {
            Task { await flight.leave() }
        }
        try await Task.sleep(for: .milliseconds(10))
        return try await request()
    }
}

private actor Flight {
    private var inFlight = 0
    private(set) var peak = 0

    func enter() {
        inFlight += 1
        peak = max(peak, inFlight)
    }

    func leave() {
        inFlight = max(0, inFlight - 1)
    }
}
