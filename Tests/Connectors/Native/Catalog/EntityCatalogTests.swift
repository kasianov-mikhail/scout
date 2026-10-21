//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorSupport
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

    @Test("Republishing the whole catalog writes nothing, aggregates included")
    func idempotentCatalog() async throws {
        let database = InMemoryDatabase()
        let registry = SchemaRegistry(database: database)
        let store = EntityStore(database: database, registry: registry)

        try await CatalogEntry.publishAll(into: store, registry: SchemaRegistry(database: database))
        database.resetRequests()

        try await CatalogEntry.publishAll(into: store, registry: SchemaRegistry(database: database))

        #expect(database.requests[.conditionalSave] == 0)
        #expect(database.requests[.modify] == 0)
    }

    @Test("An aggregate added to unchanged fields republishes the entity")
    func addedAggregateRepublishes() async throws {
        let database = InMemoryDatabase()
        let registry = SchemaRegistry(database: database)
        let store = EntityStore(database: database, registry: registry)
        let fields = [CatalogEntry.Field(name: "date", type: .timestamp)]
        let before = CatalogEntry(entity: "Probe", fields: fields, aggregates: [.count(by: "device_id", at: "date")])
        let after = CatalogEntry(
            entity: "Probe",
            fields: fields,
            aggregates: [
                .count(by: "device_id", at: "date"),
                .count(by: "install_id", at: "date", parts: 4),
            ]
        )

        try await before.publish(into: store, registry: registry)

        #expect(!after.matches(try await registry.schema(for: "Probe")))

        try await after.publish(into: store, registry: SchemaRegistry(database: database))

        #expect(after.matches(try await SchemaRegistry(database: database).schema(for: "Probe")))
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
            ScreenEntry.recordType,
            ConditionEntry.recordType,
            BacktraceEntry.recordType,
            BundledSymbols.indexType,
            BundledSymbols.fileType,
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
            EntityCatalog.derivedValues(for: record) == [CatalogEntry.metricSeriesKey: .string("timer|checkout")])
    }

    @Test("A session derives its device and system key next to its lifecycle key")
    func derivedDeviceSystem() throws {
        var record = Record(recordType: SessionEntry.recordType, recordID: "s-1")
        record["device_id"] = "D1"
        record["os_version"] = "iOS 17.4"

        let derived = EntityCatalog.derivedValues(for: record)
        let key = try #require(derived[CatalogEntry.deviceSystem])

        #expect(key == .string("D1|iOS 17.4"))
        #expect(derived[CatalogEntry.lifecycleKey] != nil)
    }

    @Test("A device and system key splits back, with a missing system read as nil")
    func deviceSystemRoundTrip() throws {
        let full = try #require(DeviceSystem(key: DeviceSystem(device: "D1", system: "iOS 17.4").key))
        let bare = try #require(DeviceSystem(key: DeviceSystem(device: "D2", system: nil).key))

        #expect(full.device == "D1")
        #expect(full.system == "iOS 17.4")
        #expect(bare.device == "D2")
        #expect(bare.system == nil)
        #expect(DeviceSystem(key: "") == nil)
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
        let key = CatalogEntry.encodeSeriesKey(category: category, name: name)
        let decoded = try #require(CatalogEntry.decodeSeriesKey(key))
        #expect(decoded.category == category)
        #expect(decoded.name == name)
    }

    @Test("A packed pipe no longer truncates the category")
    func seriesKeyDoesNotSplitOnPackedPipe() throws {
        let key = CatalogEntry.encodeSeriesKey(category: "billing|eu", name: "renew")
        let decoded = try #require(CatalogEntry.decodeSeriesKey(key))
        #expect(decoded.category == "billing|eu")
        #expect(decoded.name == "renew")
    }

    @Test("A lifecycle key splits back into name, category and version, separators included")
    func lifecycleKeyRoundTrip() {
        var record = Record(recordType: DailyMetricEntry.recordType, recordID: "m-1")
        record["name"] = "exit|reason"
        record["category"] = "watch\\dog"
        record["app_version"] = "1.2.0"

        guard case .string(let encoded)? = CatalogEntry.metricLifecycleKey(for: record)[CatalogEntry.lifecycleKey] else {
            Issue.record("The metric carries no lifecycle key")
            return
        }
        let key = LifecycleKey(encoded)

        #expect(key.name == "exit|reason")
        #expect(key.category == "watch\\dog")
        #expect(key.version == "1.2.0")
        #expect(LifecycleKey("||1.0").category == nil)
    }

    @Test("Legacy separator-free keys decode unchanged")
    func seriesKeyDecodesLegacyValues() throws {
        let decoded = try #require(CatalogEntry.decodeSeriesKey("timer|checkout"))
        #expect(decoded.category == "timer")
        #expect(decoded.name == "checkout")
    }
}
