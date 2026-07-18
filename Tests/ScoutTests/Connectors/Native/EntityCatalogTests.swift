//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutDB
import Testing

@testable import NativeConnector
@testable import Scout

@Suite("EntityCatalog")
struct EntityCatalogTests {
    @Test("Every definition passes scout-db validation")
    func validation() throws {
        for definition in EntityCatalog.definitions {
            try definition.validate()
        }
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
            #expect(EntityCatalog.definition(for: entity) != nil)
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
            let definition = try #require(EntityCatalog.definition(for: entity))
            let fields = Set(definition.fields.map(\.name))
            // The uuid field lives in the Item envelope rather than a slot.
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
}
