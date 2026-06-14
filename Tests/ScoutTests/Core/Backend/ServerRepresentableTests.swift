//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation
import Testing

@testable import Scout

@MainActor
@Suite("ServerRepresentable")
struct ServerRepresentableTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("CloudKit-representable types reuse their CloudKit record")
    func reusesCloudKitRecord() throws {
        let event = EventObject.stub(name: "login", in: context)
        try context.save()

        let record = event.toServerRecord

        #expect(record.recordType == "Event")
        #expect(record["name"] == "login")
        #expect(record.id == event.toRecord.id)
    }

    @Test("Int metrics serialize as raw IntMetric records")
    func intMetricRecord() throws {
        let metric = IntMetricsObject.stub(name: "requests", telemetry: "counter", value: 5, in: context)
        try context.save()

        let record = metric.toServerRecord

        #expect(record.recordType == "IntMetric")
        #expect(record["name"] == "requests")
        #expect(record["category"] == "counter")
        #expect(record["value"] == 5)
        #expect(record.fields["week"] != nil)
        #expect(record.fields["install_id"] != nil)
    }

    @Test("Metric record names are stable across repeated serialization")
    func stableMetricRecordName() throws {
        let metric = DoubleMetricsObject.stub(name: "duration", telemetry: "timer", value: 1.5, in: context)
        try context.save()

        let record = metric.toServerRecord

        #expect(record.recordType == "DoubleMetric")
        #expect(record["value"] == 1.5)
        #expect(record.id == metric.toServerRecord.id)
    }
}

// MARK: - Stubs

extension IntMetricsObject {
    @discardableResult static func stub(name: String, telemetry: String, value: Int, in context: NSManagedObjectContext) -> IntMetricsObject {
        let entity = NSEntityDescription.entity(forEntityName: "IntMetricsObject", in: context)!
        let metric = IntMetricsObject(entity: entity, insertInto: context)

        metric.name = name
        metric.telemetry = telemetry
        metric.value = value
        metric.date = Date()

        return metric
    }
}

extension DoubleMetricsObject {
    @discardableResult static func stub(name: String, telemetry: String, value: Double, in context: NSManagedObjectContext) -> DoubleMetricsObject {
        let entity = NSEntityDescription.entity(forEntityName: "DoubleMetricsObject", in: context)!
        let metric = DoubleMetricsObject(entity: entity, insertInto: context)

        metric.name = name
        metric.telemetry = telemetry
        metric.value = value
        metric.date = Date()

        return metric
    }
}
