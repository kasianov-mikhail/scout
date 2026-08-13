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
        try await CatalogEntry.publishAll(into: store, registry: registry)

        for entry in CatalogEntry.entries {
            let published = try await registry.schema(for: entry.entity)
            #expect(entry.matches(published), "\(entry.entity) was published with a different shape")
        }
    }

    @Test("Entities reconcile together rather than one after another")
    func publishesConcurrently() async throws {
        try await CatalogEntry.publishAll(into: store, registry: registry)

        #expect(await probe.peak > 1, "the catalog was published one entity at a time")
    }

    @Test("An outage surfaces instead of reading as a blank slate to re-create over")
    func outagePropagates() async {
        let outage = Outage()
        let registry = SchemaRegistry(database: outage)
        let store = EntityStore(database: outage, registry: registry)

        await #expect(throws: CKError.self) {
            try await CatalogEntry.publishAll(into: store, registry: registry)
        }

        #expect(await outage.saves == 0, "a failed schema fetch was answered with a create")
    }

    @Test("A transient fetch failure never republishes over a live schema")
    func transientFailureLeavesSchemaAlone() async throws {
        let entry = try #require(CatalogEntry.entries.first)
        try await store.schema(entry.entity)
            .field("legacy", .string)
            .create()

        let outage = FetchOutage(database: probe)
        let registry = SchemaRegistry(database: outage)
        let store = EntityStore(database: outage, registry: registry)

        await #expect(throws: CKError.self) {
            try await entry.publish(into: store, registry: registry)
        }

        let published = try await SchemaRegistry(database: probe).schema(for: entry.entity)
        #expect(published.fields.map(\.name) == ["legacy"])
    }
}

private actor Outage: CloudDatabase {
    private(set) var saves = 0

    func records(matching query: CKQuery, resultsLimit: Int) async throws -> QueryPage {
        throw CKError(.networkUnavailable)
    }

    func records(continuingMatchFrom cursor: QueryCursor, resultsLimit: Int) async throws -> QueryPage {
        throw CKError(.networkUnavailable)
    }

    func modifyRecords(saving: [CKRecord], deleting: [CKRecord.ID]) async throws {
        saves += 1
        throw CKError(.networkUnavailable)
    }

    func saveIfUnchanged(_ records: [CKRecord]) async throws -> [(CKRecord.ID, Result<CKRecord, any Error>)] {
        throw CKError(.networkUnavailable)
    }

    func fetchRecord(id: CKRecord.ID) async throws -> CKRecord? {
        throw CKError(.networkUnavailable)
    }

    func fetchRecords(ids: [CKRecord.ID]) async throws -> [CKRecord] {
        throw CKError(.networkUnavailable)
    }
}

/// Forwards to another database while every record fetch fails like a network
/// drop, so a wrongly attempted write still lands where a test can see it.
///
private struct FetchOutage: CloudDatabase {
    let database: any CloudDatabase

    func records(matching query: CKQuery, resultsLimit: Int) async throws -> QueryPage {
        try await database.records(matching: query, resultsLimit: resultsLimit)
    }

    func records(continuingMatchFrom cursor: QueryCursor, resultsLimit: Int) async throws -> QueryPage {
        try await database.records(continuingMatchFrom: cursor, resultsLimit: resultsLimit)
    }

    func modifyRecords(saving: [CKRecord], deleting: [CKRecord.ID]) async throws {
        try await database.modifyRecords(saving: saving, deleting: deleting)
    }

    func saveIfUnchanged(_ records: [CKRecord]) async throws -> [(CKRecord.ID, Result<CKRecord, any Error>)] {
        try await database.saveIfUnchanged(records)
    }

    func fetchRecord(id: CKRecord.ID) async throws -> CKRecord? {
        throw CKError(.networkUnavailable)
    }

    func fetchRecords(ids: [CKRecord.ID]) async throws -> [CKRecord] {
        try await database.fetchRecords(ids: ids)
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
