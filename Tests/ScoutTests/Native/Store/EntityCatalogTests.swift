//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutDB
import Testing

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
            EventObject.recordType,
            SessionObject.recordType,
            LaunchObject.recordType,
            InstallObject.recordType,
            DeviceObject.recordType,
            VersionObject.recordType,
            CrashObject.recordType,
            IntMetricsObject.recordType,
            DoubleMetricsObject.recordType,
        ]
        for entity in entities {
            #expect(EntityCatalog.definition(for: entity) != nil)
        }
    }

    @Test("Definitions cover the fields the UI requests")
    func desiredKeys() throws {
        let requests: [(String, [String])] = [
            (EventObject.recordType, Event.desiredKeys),
            (SessionObject.recordType, Session.desiredKeys),
            (LaunchObject.recordType, Launch.desiredKeys),
            (InstallObject.recordType, Install.desiredKeys),
            (DeviceObject.recordType, Device.desiredKeys),
            (VersionObject.recordType, Version.desiredKeys),
            (CrashObject.recordType, Crash.desiredKeys),
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

    @Test("Series key packs category and name")
    func seriesKey() {
        var record = Record(recordType: IntMetricsObject.recordType, recordID: "m-1")
        record["name"] = "checkout"
        record["category"] = "timer"

        #expect(EntityCatalog.seriesKey(for: record) == .string("timer|checkout"))
        #expect(EntityCatalog.seriesKey(for: Record(recordType: EventObject.recordType, recordID: "e-1")) == nil)
    }
}
