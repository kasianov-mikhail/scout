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
@testable import Support

@MainActor
@Suite("Record encoding")
struct RecordEncodingTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Events encode to a raw Event record")
    func eventRecord() throws {
        let event = EventEntry.stub(name: "login", in: context)
        try context.save()

        let record = event.record

        #expect(record.recordType == "Event")
        #expect(record["name"] == "login")
    }

    @Test("Int metrics serialize as raw IntMetric records")
    func intMetricRecord() throws {
        let device = DeviceEntry.stub(date: Date(), in: context)
        let install = InstallEntry.stub(date: Date(), device: device, in: context)
        let launch = LaunchEntry.stub(date: Date(), install: install, in: context)
        let session = SessionEntry.stub(date: Date(), launch: launch, in: context)

        let metric = IntMetricsEntry.stub(name: "requests", telemetry: "counter", value: 5, in: context)
        metric.session = session
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
        let metric = DoubleMetricsEntry.stub(name: "duration", telemetry: "timer", value: 1.5, in: context)
        try context.save()

        let record = metric.record

        #expect(record.recordType == "DoubleMetric")
        #expect(record["value"] == 1.5)
        #expect(record.recordID == metric.record.recordID)
    }

    @Test("Session records carry the app version")
    func sessionAppVersionRecord() throws {
        let session = SessionEntry.stub(date: Date(), appVersion: "3.2.0", in: context)
        try context.save()

        #expect(session.record.recordType == "Session")
        #expect(session.record["app_version"] == "3.2.0")
    }

    @Test("Session records carry the runtime environment")
    func sessionEnvironmentRecord() throws {
        let session = SessionEntry.stub(date: Date(), in: context)
        session.buildNumber = "412"
        session.osVersion = "iOS 17.4"
        session.locale = "en_US"
        session.channel = "TestFlight"
        try context.save()

        #expect(session.record["build_number"] == "412")
        #expect(session.record["os_version"] == "iOS 17.4")
        #expect(session.record["locale"] == "en_US")
        #expect(session.record["channel"] == "TestFlight")
    }

    @Test("Device records carry the hardware model")
    func deviceModelRecord() throws {
        let device = DeviceEntry.stub(date: Date(), in: context)
        device.model = "iPhone16,1"
        try context.save()

        #expect(device.record.recordType == "Device")
        #expect(device.record["model"] == "iPhone16,1")
    }

    @Test("Visit records get a deterministic device-day name")
    func visitRecord() throws {
        let device = DeviceEntry.stub(date: Date(), in: context)
        let install = InstallEntry.stub(date: Date(), device: device, in: context)
        let launch = LaunchEntry.stub(date: Date(), install: install, in: context)

        let visit = context.insert(VisitEntry.self)
        visit.visitID = UUID()
        visit.date = Date()
        visit.launch = launch
        try context.save()

        let record = visit.record

        #expect(record.recordType == "Visit")
        #expect(record["device_id"] == device.deviceID.uuidString)
        #expect(record.recordID == "\(device.deviceID.uuidString)-\(visit.day?.millisecondsSince1970 ?? 0)")
        #expect(record.fields["date"] != nil)
    }

    @Test("Crash records carry the app version")
    func crashAppVersionRecord() throws {
        let crash = CrashEntry(
            entity: NSEntityDescription.entity(forEntityName: "CrashEntry", in: context)!, insertInto: context)
        crash.name = "SIGABRT"
        crash.crashID = UUID()
        crash.appVersion = "3.2.0"
        crash.date = Date()
        try context.save()

        #expect(crash.record["app_version"] == "3.2.0")
    }
}

extension IntMetricsEntry {
    @discardableResult static func stub(name: String, telemetry: String, value: Int, in context: NSManagedObjectContext)
        -> IntMetricsEntry
    {
        let entity = NSEntityDescription.entity(forEntityName: "IntMetricsEntry", in: context)!
        let metric = IntMetricsEntry(entity: entity, insertInto: context)

        metric.name = name
        metric.telemetry = telemetry
        metric.value = value
        metric.date = Date()

        return metric
    }
}

extension DoubleMetricsEntry {
    @discardableResult static func stub(
        name: String, telemetry: String, value: Double, in context: NSManagedObjectContext
    ) -> DoubleMetricsEntry {
        let entity = NSEntityDescription.entity(forEntityName: "DoubleMetricsEntry", in: context)!
        let metric = DoubleMetricsEntry(entity: entity, insertInto: context)

        metric.name = name
        metric.telemetry = telemetry
        metric.value = value
        metric.date = Date()

        return metric
    }
}
