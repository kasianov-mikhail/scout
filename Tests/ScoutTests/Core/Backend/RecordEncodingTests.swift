//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData
import Foundation
import Testing

@testable import Scout

@MainActor
@Suite("Record encoding")
struct RecordEncodingTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Events encode to a raw Event record")
    func eventRecord() throws {
        let event = EventObject.stub(name: "login", in: context)
        try context.save()

        let record = event.record

        #expect(record.recordType == "Event")
        #expect(record["name"] == "login")
    }

    @Test("Int metrics serialize as raw IntMetric records")
    func intMetricRecord() throws {
        let metric = IntMetricsObject.stub(name: "requests", telemetry: "counter", value: 5, in: context)
        try context.save()

        let record = metric.record

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

        let record = metric.record

        #expect(record.recordType == "DoubleMetric")
        #expect(record["value"] == 1.5)
        #expect(record.recordID == metric.record.recordID)
    }

    @Test("Session records carry the app version")
    func sessionAppVersionRecord() throws {
        let session = SessionObject.stub(date: Date(), appVersion: "3.2.0", in: context)
        try context.save()

        #expect(session.record.recordType == "Session")
        #expect(session.record["app_version"] == "3.2.0")
    }

    @Test("Crash records carry the app version")
    func crashAppVersionRecord() throws {
        let crash = CrashObject(entity: NSEntityDescription.entity(forEntityName: "CrashObject", in: context)!, insertInto: context)
        crash.name = "SIGABRT"
        crash.crashID = UUID()
        crash.appVersion = "3.2.0"
        crash.date = Date()
        try context.save()

        #expect(crash.record["app_version"] == "3.2.0")
    }

    @Test("Crash fingerprint is written to CloudKit records")
    func crashFingerprintCloudKitRecord() throws {
        let crash = CrashObject(entity: NSEntityDescription.entity(forEntityName: "CrashObject", in: context)!, insertInto: context)
        crash.name = "SIGABRT"
        crash.crashID = UUID()
        crash.fingerprint = "fingerprint"
        crash.date = Date()
        try context.save()

        let ckRecord = crash.record.ckRecord

        #expect(ckRecord.recordType == "Crash")
        #expect(ckRecord["fingerprint"] as? String == "fingerprint")
    }
}

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
