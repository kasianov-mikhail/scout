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

extension NativeSeriesTests {
    @Test("A meter series keeps the last value in each bucket, not the sum")
    func meterLastValue() async throws {
        let hour = TestDate.reference.addingTimeInterval(10 * .hour)
        try await database.write(
            record: makeMeterRecord(id: "g-1", name: "queue_depth", value: 5, date: hour.addingTimeInterval(60)))
        try await database.write(
            record: makeMeterRecord(id: "g-2", name: "queue_depth", value: 8, date: hour.addingTimeInterval(120)))

        var foreign = makeMeterRecord(id: "g-3", name: "queue_depth", value: 100, date: hour.addingTimeInterval(180))
        foreign["category"] = "timer"
        try await database.write(record: foreign)

        let series = try await database.metricSeries(Double.self, category: "meter", reduce: .last, in: range)

        let gauge = try #require(series.first { $0.name == "queue_depth" })
        #expect(gauge.category == "meter")
        #expect(gauge.points.map(\.value) == [.double(8)])
    }

    @Test("A meter resolves the last value per bucket independently")
    func meterBuckets() async throws {
        let first = TestDate.reference.addingTimeInterval(10 * .hour)
        let second = TestDate.reference.addingTimeInterval(11 * .hour)
        try await database.write(
            record: makeMeterRecord(id: "g-1", name: "queue_depth", value: 5, date: first.addingTimeInterval(60)))
        try await database.write(
            record: makeMeterRecord(id: "g-2", name: "queue_depth", value: 2, date: first.addingTimeInterval(120)))
        try await database.write(
            record: makeMeterRecord(id: "g-3", name: "queue_depth", value: 9, date: second.addingTimeInterval(60)))

        let series = try await database.metricSeries(Double.self, category: "meter", reduce: .last, in: range)

        let gauge = try #require(series.first { $0.name == "queue_depth" })
        #expect(gauge.points.map(\.value) == [.double(2), .double(9)])
    }

    @Test("A meter keeps a zero as its latest value")
    func meterZero() async throws {
        let hour = TestDate.reference.addingTimeInterval(10 * .hour)
        try await database.write(
            record: makeMeterRecord(id: "g-1", name: "queue_depth", value: 7, date: hour.addingTimeInterval(60)))
        try await database.write(
            record: makeMeterRecord(id: "g-2", name: "queue_depth", value: 0, date: hour.addingTimeInterval(120)))

        let series = try await database.metricSeries(Double.self, category: "meter", reduce: .last, in: range)

        let gauge = try #require(series.first { $0.name == "queue_depth" })
        #expect(gauge.points.map(\.value) == [.double(0)])
    }
}

func makeMeterRecord(id: String, name: String, value: Double, date: Date) -> Record {
    var record = Record(recordType: DoubleMetricsEntry.recordType, recordID: id)
    record["name"] = name
    record["category"] = "meter"
    record["value"] = value
    record["date"] = date
    record["session_id"] = "session-1"
    return record
}
