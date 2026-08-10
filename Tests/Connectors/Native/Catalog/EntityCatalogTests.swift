//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutDB
import ScoutDBTesting
import Testing

@testable import NativeConnector
@testable import Scout

@Suite("EntityCatalog")
struct EntityCatalogTests {
    @Test("Every declaration publishes, so every one of them validates")
    func validation() async throws {
        let database = InMemoryDatabase()
        let registry = SchemaRegistry(database: database)
        let store = EntityStore(database: database, registry: registry)

        for entry in CatalogEntry.entries {
            try await entry.publish(into: store, registry: registry)
        }
        for entry in CatalogEntry.entries {
            let schema = try await registry.schema(for: entry.entity)
            #expect(entry.matches(schema))
        }
    }

    @Test("Republishing an unchanged declaration leaves the schema where it is")
    func idempotentPublish() async throws {
        let database = InMemoryDatabase()
        let registry = SchemaRegistry(database: database)
        let store = EntityStore(database: database, registry: registry)
        let entry = try #require(CatalogEntry.entries.first { $0.entity == EventEntry.recordType })

        try await entry.publish(into: store, registry: registry)
        try await entry.publish(into: store, registry: registry)

        #expect(entry.matches(try await registry.schema(for: entry.entity)))
    }

    @Test("Definitions exist for every syncable record type")
    func coverage() {
        let entities = [
            EventEntry.recordType,
            SessionEntry.recordType,
            VisitEntry.recordType,
            LaunchEntry.recordType,
            InstallEntry.recordType,
            DeviceEntry.recordType,
            VersionEntry.recordType,
            CrashEntry.recordType,
            IntMetricsEntry.recordType,
            DoubleMetricsEntry.recordType,
        ]
        for entity in entities {
            #expect(CatalogEntry.entries.first { $0.entity == entity } != nil)
        }
    }

    @Test("Definitions cover the fields the UI requests")
    func desiredKeys() throws {
        let requests: [(String, [String])] = [
            (EventEntry.recordType, Event.desiredKeys),
            (SessionEntry.recordType, Session.desiredKeys),
            (LaunchEntry.recordType, Launch.desiredKeys),
            (InstallEntry.recordType, Install.desiredKeys),
            (DeviceEntry.recordType, Device.desiredKeys),
            (VersionEntry.recordType, Version.desiredKeys),
            (CrashEntry.recordType, Crash.desiredKeys),
        ]

        for (entity, keys) in requests {
            let entry = try #require(CatalogEntry.entries.first { $0.entity == entity })
            let fields = Set(entry.fields.map(\.name))
            // The uuid field lives in the record envelope rather than a slot.
            for key in keys where key != "uuid" {
                #expect(fields.contains(key), "\(entity) is missing \(key)")
            }
        }
    }

    @Test("Metric entities derive the series key from their definition")
    func derivedSeriesKey() {
        var record = Record(recordType: IntMetricsEntry.recordType, recordID: "m-1")
        record["name"] = "checkout"
        record["category"] = "timer"

        #expect(
            EntityCatalog.derivedValues(for: record) == [EntityCatalog.metricSeriesKey: .string("timer|checkout")])
    }

    @Test("Entities without a declared derivation derive nothing")
    func noDerivation() {
        let record = Record(recordType: EventEntry.recordType, recordID: "e-1")
        #expect(EntityCatalog.derivedValues(for: record).isEmpty)
    }

    @Test(
        "Series key round-trips components containing the separator or escape char",
        arguments: [
            ("timer", "checkout"),
            ("", ""),
            ("a|b", "c|d"),
            ("path\\to", "na|me"),
            ("trailing\\", "\\leading"),
            ("|", "\\"),
        ]
    )
    func seriesKeyRoundTrip(category: String, name: String) throws {
        let key = EntityCatalog.encodeSeriesKey(category: category, name: name)
        let decoded = try #require(EntityCatalog.decodeSeriesKey(key))
        #expect(decoded.category == category)
        #expect(decoded.name == name)
    }

    @Test("A packed pipe no longer truncates the category")
    func seriesKeyDoesNotSplitOnPackedPipe() throws {
        let key = EntityCatalog.encodeSeriesKey(category: "billing|eu", name: "renew")
        let decoded = try #require(EntityCatalog.decodeSeriesKey(key))
        #expect(decoded.category == "billing|eu")
        #expect(decoded.name == "renew")
    }

    @Test("Legacy separator-free keys decode unchanged")
    func seriesKeyDecodesLegacyValues() throws {
        let decoded = try #require(EntityCatalog.decodeSeriesKey("timer|checkout"))
        #expect(decoded.category == "timer")
        #expect(decoded.name == "checkout")
    }
}
