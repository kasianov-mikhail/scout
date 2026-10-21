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
@testable import Support

@Suite("Native audience reads match the raw record scan")
struct NativeAudienceParityTests {
    @Test("Activity from visit vectors matches the raw visit scan", arguments: [false, true])
    func activity(legacy: Bool) async throws {
        let audience = try await AudienceStore(legacy: legacy)

        for range in [day(0)..<day(75), day(20)..<day(60)] {
            let raw = try await audience.rawActivity(in: range)

            #expect(!raw.isEmpty)
            #expect(try await audience.database.activity(in: range).map(\.values) == raw.map(\.values))
        }
    }

    @Test("Retention from session vectors matches the raw session scan", arguments: [false, true])
    func retention(legacy: Bool) async throws {
        let audience = try await AudienceStore(legacy: legacy)

        for range in [day(0)..<day(75), day(7)..<day(49)] {
            let raw = try await audience.rawRetention(in: range)

            #expect(raw.contains { !$0.segments.isEmpty })
            #expect(try await audience.database.retention(in: range) == raw)
        }
    }
}

private struct AudienceStore {
    let store: EntityStore
    let database: NativeDatabase

    init(legacy: Bool) async throws {
        let cloud = ScoutDBTesting.InMemoryDatabase()
        let registry = SchemaRegistry(database: cloud)
        let writer = EntityStore(database: cloud, registry: registry)

        for entry in CatalogEntry.entries {
            try await (legacy ? entry.legacy : entry).publish(into: writer, registry: registry)
        }

        try await NativeDatabase { writer }.write(records: makeAudienceRecords())

        guard legacy else {
            store = writer
            database = NativeDatabase { writer }
            return
        }

        let published = SchemaRegistry(database: cloud)
        let reader = EntityStore(database: cloud, registry: published)
        try await CatalogEntry.publishAll(into: reader, registry: published)

        store = reader
        database = NativeDatabase { reader }
    }

    func rawActivity(in range: Range<Date>) async throws -> [ActivityPoint] {
        let visits = try await store.datedIDs(
            entity: VisitEntry.recordType,
            dateField: "date",
            idField: "device_id",
            in: range.lowerBound.addingTimeInterval(-30 * .day).startOfDay..<range.upperBound
        )
        return ActivityPoint.points(visits: visits, in: range)
    }

    func rawRetention(in range: Range<Date>) async throws -> [RetentionCohort] {
        let sessions = try await store.records(
            entity: SessionEntry.recordType,
            dateField: "start_date",
            fields: ["start_date", "install_id", "os_version"],
            in: range
        )

        return try await RetentionCohort.cohorts(
            installs: store.datedIDs(entity: InstallEntry.recordType, dateField: "date", idField: "install_id", in: range),
            sessions: sessions.compactMap { record -> InstallSession? in
                let install: String? = record["install_id"]
                let start: Date? = record["start_date"]
                guard let install, let start else {
                    return nil
                }
                return InstallSession(install: install, date: start, os: record["os_version"])
            },
            crashes: store.datedIDs(entity: CrashEntry.recordType, dateField: "date", idField: "install_id", in: range),
            hangs: store.datedIDs(entity: HangEntry.recordType, dateField: "date", idField: "install_id", in: range),
            range: range,
            now: Date()
        )
    }
}

extension CatalogEntry {
    fileprivate var legacy: CatalogEntry {
        let metadata = Set(CatalogEntry(entity: entity, fields: []).fields.map(\.name))

        return CatalogEntry(
            entity: entity,
            fields: fields.filter { !metadata.contains($0.name) },
            aggregates: entity == VisitEntry.recordType ? [] : aggregates.filter { !$0.isInstallKeyed },
            derive: derive
        )
    }
}

extension CatalogEntry.Aggregate {
    fileprivate var isInstallKeyed: Bool {
        guard case .count(let group, _, _) = self else {
            return false
        }
        return group == "install_id"
    }
}

extension ActivityPoint {
    fileprivate var values: [Int64] {
        [date, Int64(dau), Int64(wau), Int64(mau)]
    }
}

private func day(_ index: Int, hour: Int = 0, minute: Int = 0) -> Date {
    TestDate.reference.addingTimeInterval(TimeInterval(index) * .day + TimeInterval(hour) * .hour + TimeInterval(minute * 60))
}

private func makeAudienceRecords() -> [Record] {
    var records: [Record] = []

    for index in 0..<12 {
        let device = "device-\(index)"
        let installDay = (index * 3) % 20
        let reinstallDay = index.isMultiple(of: 5) ? 40 : 70
        let spans = [("\(device)-a", installDay..<reinstallDay), ("\(device)-b", reinstallDay..<70)]

        for (install, days) in spans where !days.isEmpty {
            records.append(makeInstall(id: install, device: device, date: day(days.lowerBound, hour: index)))

            for current in days where current == days.lowerBound || (current * 7 + index) % 3 != 0 {
                let first = current == days.lowerBound
                let start = first ? day(current, hour: index, minute: 5) : day(current, hour: (index + current) % 24)
                let os = first && index.isMultiple(of: 4) ? nil : current < 30 ? "iOS 17.\(index % 3)" : "iOS 18.0"

                records.append(makeSession(id: "\(install)-\(current)", install: install, device: device, start: start, os: os))
                records.append(makeVisit(device: device, date: start))

                if current.isMultiple(of: 4) {
                    records.append(makeSession(id: "\(install)-\(current)-late", install: install, device: device, start: day(current, hour: 23), os: os))
                }
            }

            if index.isMultiple(of: 3) {
                records.append(makeIncident(entity: CrashEntry.recordType, install: install, date: day(days.lowerBound + 2, hour: 12)))
                records.append(makeIncident(entity: CrashEntry.recordType, install: install, date: day(days.lowerBound + 40, hour: 12)))
            }
            if index % 4 == 1 {
                records.append(makeIncident(entity: HangEntry.recordType, install: install, date: day(days.lowerBound + 10, hour: 8)))
            }
        }
    }

    records.append(makeVisit(device: nil, date: day(5, hour: 3)))
    records.append(makeSession(id: "orphan", install: nil, device: "device-1", start: day(5, hour: 3), os: "iOS 16.0"))

    return records
}

private func makeInstall(id: String, device: String, date: Date) -> Record {
    var record = Record(recordType: InstallEntry.recordType, recordID: id)
    record["date"] = date
    record["install_id"] = id
    record["device_id"] = device
    return record
}

private func makeSession(id: String, install: String?, device: String, start: Date, os: String?) -> Record {
    var record = Record(recordType: SessionEntry.recordType, recordID: id)
    record["start_date"] = start
    record["end_date"] = start.addingTimeInterval(10 * 60)
    record["session_id"] = id
    record["app_version"] = "1.2.0"
    record["device_id"] = device
    record["install_id"] = install
    record["os_version"] = os
    return record
}

private func makeVisit(device: String?, date: Date) -> Record {
    var record = Record(recordType: VisitEntry.recordType, recordID: "\(device ?? "orphan")-\(date.startOfDay.millisecondsSince1970)")
    record["date"] = date
    record["device_id"] = device
    return record
}

private func makeIncident(entity: String, install: String, date: Date) -> Record {
    var record = Record(recordType: entity, recordID: "\(entity)-\(install)-\(date.millisecondsSince1970)")
    record["date"] = date
    record["name"] = "EXC_BAD_ACCESS"
    record["fingerprint"] = "fingerprint"
    record["install_id"] = install
    return record
}
