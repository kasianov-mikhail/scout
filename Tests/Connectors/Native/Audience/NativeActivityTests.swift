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

@Suite("Native activity from visit gaps")
struct NativeActivityTests {
    @Test("Activity of devices that stamp gaps comes from the gap series alone")
    func stampedActivity() async throws {
        let visits = makeVisits()
        let database = try await makeDatabase(records: visits.flatMap { [$0.session(version: "2.0"), $0.gapRecord] })

        for range in [day(0)..<day(90), day(40)..<day(75, hour: 6)] {
            let expected = ActivityPoint.points(visits: visits.map(\.datedID), in: range)

            #expect(!expected.isEmpty)
            #expect(try await database.activity(in: range).map(\.values) == expected.map(\.values))
        }
    }

    @Test("Activity falls back to device visits while an old version still reports")
    func mixedActivity() async throws {
        let visits = makeVisits()
        let records = visits.flatMap { visit in
            let isStamped = visit.offset >= visit.upgradeDay
            let session = visit.session(version: isStamped ? "2.0" : "1.0")
            return isStamped ? [visit.visitRecord, session, visit.upgradedGapRecord(visits: visits)] : [visit.visitRecord, session]
        }
        let database = try await makeDatabase(records: records)

        for range in [day(0)..<day(90), day(20)..<day(60), day(70)..<day(90)] {
            let expected = ActivityPoint.points(visits: visits.map(\.datedID), in: range)

            #expect(!expected.isEmpty)
            #expect(try await database.activity(in: range).map(\.values) == expected.map(\.values))
        }
    }
}

private struct Visit {
    let device: Int
    let offset: Int
    let gap: Int

    var upgradeDay: Int {
        10 + device * 3
    }

    var date: Date {
        day(offset, hour: (device * 5 + offset) % 24)
    }

    var datedID: DatedID {
        DatedID(date: date, id: "device-\(device)")
    }

    var visitRecord: Record {
        var record = Record(recordType: VisitEntry.recordType, recordID: "device-\(device)-\(offset)")
        record["date"] = date
        record["device_id"] = "device-\(device)"
        return record
    }

    var gapRecord: Record {
        gapRecord(gap: gap)
    }

    func upgradedGapRecord(visits: [Visit]) -> Record {
        let isFirstStamped = !visits.contains { $0.device == device && $0.offset >= upgradeDay && $0.offset < offset }
        return gapRecord(gap: isFirstStamped ? VisitGapEntry.cap : gap)
    }

    func session(version: String) -> Record {
        var record = Record(recordType: SessionEntry.recordType, recordID: "session-\(device)-\(offset)")
        record["start_date"] = date
        record["session_id"] = "session-\(device)-\(offset)"
        record["app_version"] = version
        record["device_id"] = "device-\(device)"
        return record
    }

    private func gapRecord(gap: Int) -> Record {
        var record = Record(recordType: VisitGapEntry.recordType, recordID: "device-\(device)-\(offset)")
        record["date"] = date
        record["gap"] = String(gap)
        record["app_version"] = "2.0"
        record["device_id"] = "device-\(device)"
        return record
    }
}

private func makeVisits() -> [Visit] {
    (0..<10).flatMap { device in
        var visits: [Visit] = []
        var previous: Int?

        for current in 0..<90 where isVisit(device: device, day: current) {
            let gap = previous.map { min(current - $0, VisitGapEntry.cap) } ?? VisitGapEntry.cap
            visits.append(Visit(device: device, offset: current, gap: gap))
            previous = current
        }
        return visits
    }
}

private func isVisit(device: Int, day: Int) -> Bool {
    switch device % 4 {
    case 3:
        (day * 5 + device).isMultiple(of: 37)
    case 2:
        (day * 3 + device).isMultiple(of: 11)
    default:
        (day * 37 + device * 11) % 7 < 2 + device % 3
    }
}

private func makeDatabase(records: [Record]) async throws -> NativeDatabase {
    let cloud = ScoutDBTesting.InMemoryDatabase()
    let registry = SchemaRegistry(database: cloud)
    let store = EntityStore(database: cloud, registry: registry)

    try await CatalogEntry.publishAll(into: store, registry: registry)

    let database = NativeDatabase { store }
    try await database.write(records: records)
    return database
}

extension ActivityPoint {
    fileprivate var values: [Int64] {
        [date, Int64(dau), Int64(wau), Int64(mau)]
    }
}

private func day(_ index: Int, hour: Int = 0) -> Date {
    TestDate.reference.addingTimeInterval(TimeInterval(index) * .day + TimeInterval(hour) * .hour)
}
