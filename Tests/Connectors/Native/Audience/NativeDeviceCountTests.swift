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
@testable import Support

@Suite("Native device counts from visit gaps")
struct NativeDeviceCountTests {
    private let visits = makeVisits()

    @Test("Week counts devices with a visit from the gaps and skips session-only devices")
    func week() async throws {
        let database = try await makeDatabase(extra: [ghostSession])
        let ranges = [day(83)..<day(90), day(76)..<day(83)] + (83..<90).map { day($0)..<day($0 + 1) }

        #expect(try await database.deviceCounts(in: ranges) == ranges.map(visitDevices))
    }

    @Test("Month slices count the days that start in them, and a 31-day month counts its last 30 days")
    func month() async throws {
        let database = try await makeDatabase(extra: [ghostSession])
        let ranges = [day(60)..<day(90), day(29)..<day(60)] + slices(of: day(60)..<day(90))
        let windows = [day(60)..<day(90), day(30)..<day(60)] + slices(of: day(60)..<day(90))

        #expect(visitDevices(in: day(29)..<day(60)) > visitDevices(in: day(30)..<day(60)))
        #expect(try await database.deviceCounts(in: ranges) == windows.map(visitDevices))
    }

    @Test("Ranges shorter than a day send every range to the session devices")
    func today() async throws {
        let ghost = Session(device: "ghost", date: day(89, hour: 12), version: "2.0")
        let database = try await makeDatabase(extra: [ghost])
        let ranges = [day(89)..<day(90), day(88)..<day(89)] + slices(of: day(89)..<day(90))

        #expect(try await database.deviceCounts(in: ranges) == ranges.map { sessionDevices(in: $0, extra: [ghost]) })
    }

    @Test("A session without a device is not counted as a device")
    func deviceless() async throws {
        var deviceless = Session(device: "", date: day(89, hour: 12), version: "2.0").record
        deviceless.fields["device_id"] = nil
        let database = try await makeDatabase(extra: [])
        try await database.write(record: deviceless)
        let ranges = [day(89)..<day(90)] + slices(of: day(89)..<day(90))

        #expect(try await database.deviceCounts(in: ranges) == ranges.map { sessionDevices(in: $0, extra: []) })
    }

    @Test("Ranges longer than a month send every range to the session devices")
    func year() async throws {
        let database = try await makeDatabase(extra: [ghostSession])
        let ranges = [day(45)..<day(90), day(0)..<day(45)] + slices(of: day(45)..<day(90))

        #expect(try await database.deviceCounts(in: ranges) == ranges.map { sessionDevices(in: $0, extra: [ghostSession]) })
    }

    @Test("A range with a day of an old version falls back to the session devices alone")
    func unstamped() async throws {
        let legacy = Session(device: "legacy", date: day(86, hour: 3), version: "1.0")
        let database = try await makeDatabase(extra: [ghostSession, legacy])
        let ranges = [day(83)..<day(90), day(76)..<day(83)] + (83..<90).map { day($0)..<day($0 + 1) }

        let expected = ranges.map { range in
            range.contains(legacy.date) ? sessionDevices(in: range, extra: [ghostSession, legacy]) : visitDevices(in: range)
        }

        #expect(expected[0] == visitDevices(in: ranges[0]) + 2)
        #expect(try await database.deviceCounts(in: ranges) == expected)
    }

    private var ghostSession: Session {
        Session(device: "ghost", date: day(85, hour: 12), version: "2.0")
    }

    private func makeDatabase(extra: [Session]) async throws -> NativeDatabase {
        let database = NativeDatabase.inMemory()
        try await database.write(records: visits.flatMap(\.records) + extra.map(\.record))
        return database
    }

    private func visitDevices(in window: Range<Date>) -> Int {
        Set(visits.filter { window.contains(day($0.offset)) }.map(\.device)).count
    }

    private func sessionDevices(in range: Range<Date>, extra: [Session]) -> Int {
        Set((visits.map(\.session) + extra).filter { range.contains($0.date) }.map(\.device)).count
    }
}

private struct Visit {
    let device: Int
    let offset: Int
    let gap: Int

    var session: Session {
        Session(device: "device-\(device)", date: day(offset, hour: (device * 5 + offset) % 24), version: "2.0")
    }

    var records: [Record] {
        var record = Record(recordType: VisitGapEntry.recordType, recordID: "gap-\(device)-\(offset)")
        record["date"] = session.date
        record["gap"] = String(gap)
        record["app_version"] = "2.0"
        record["device_id"] = session.device
        return [record, session.record]
    }
}

private struct Session {
    let device: String
    let date: Date
    let version: String

    var record: Record {
        let id = "session-\(device)-\(date.timeIntervalSince1970)"
        var record = Record(recordType: SessionEntry.recordType, recordID: id)
        record["start_date"] = date
        record["session_id"] = id
        record["app_version"] = version
        record["device_id"] = device
        return record
    }
}

private func makeVisits() -> [Visit] {
    let firstDayOnly = Visit(device: 99, offset: 29, gap: VisitGapEntry.cap)

    return [firstDayOnly]
        + (0..<12).flatMap { device in
            var visits: [Visit] = []
            var previous: Int?

            for current in 0..<90 where (current + device * 3).isMultiple(of: device * 4 + 1) {
                let gap = previous.map { min(current - $0, VisitGapEntry.cap) } ?? VisitGapEntry.cap
                visits.append(Visit(device: device, offset: current, gap: gap))
                previous = current
            }
            return visits
        }
}

private func slices(of range: Range<Date>) -> [Range<Date>] {
    let step = range.upperBound.timeIntervalSince(range.lowerBound) / 7

    return (0..<7).map { index in
        range.lowerBound.addingTimeInterval(step * Double(index))..<range.lowerBound.addingTimeInterval(step * Double(index + 1))
    }
}

private func day(_ index: Int, hour: Int = 0) -> Date {
    TestDate.reference.addingTimeInterval(TimeInterval(index) * .day + TimeInterval(hour) * .hour)
}
