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

private let window = TestDate.reference..<TestDate.reference.addingTimeInterval(2 * .day)

extension NativeSeriesTests {
    @Test("A meter series keeps the peak value in each bucket, not the sum")
    func meterPeak() async throws {
        let hour = TestDate.reference.addingTimeInterval(10 * .hour)
        try await database.write(
            record: makeMeterRecord(id: "g-1", name: "queue_depth", value: 8, date: hour.addingTimeInterval(60)))
        try await database.write(
            record: makeMeterRecord(id: "g-2", name: "queue_depth", value: 5, date: hour.addingTimeInterval(120)))

        var foreign = makeMeterRecord(id: "g-3", name: "queue_depth", value: 100, date: hour.addingTimeInterval(180))
        foreign["category"] = "timer"
        try await database.write(record: foreign)

        let series = try await database.metricSeries(matching: meters)

        let gauge = try #require(series.first { $0.name == "queue_depth" })
        #expect(gauge.category == "meter")
        #expect(gauge.points.map(\.value) == [8])
    }

    @Test("A meter resolves the peak per bucket independently")
    func meterBuckets() async throws {
        let first = TestDate.reference.addingTimeInterval(10 * .hour)
        let second = TestDate.reference.addingTimeInterval(11 * .hour)
        try await database.write(
            record: makeMeterRecord(id: "g-1", name: "queue_depth", value: 5, date: first.addingTimeInterval(60)))
        try await database.write(
            record: makeMeterRecord(id: "g-2", name: "queue_depth", value: 2, date: first.addingTimeInterval(120)))
        try await database.write(
            record: makeMeterRecord(id: "g-3", name: "queue_depth", value: 9, date: second.addingTimeInterval(60)))

        let series = try await database.metricSeries(matching: meters)

        let gauge = try #require(series.first { $0.name == "queue_depth" })
        #expect(gauge.points.map(\.value) == [5, 9])
    }

    @Test("A meter keeps a zero as its peak")
    func meterZero() async throws {
        let hour = TestDate.reference.addingTimeInterval(10 * .hour)
        try await database.write(
            record: makeMeterRecord(id: "g-1", name: "queue_depth", value: -7, date: hour.addingTimeInterval(60)))
        try await database.write(
            record: makeMeterRecord(id: "g-2", name: "queue_depth", value: 0, date: hour.addingTimeInterval(120)))

        let series = try await database.metricSeries(matching: meters)

        let gauge = try #require(series.first { $0.name == "queue_depth" })
        #expect(gauge.points.map(\.value) == [0])
    }

    @Test("A meter series reads the peak aggregate, not the records")
    func meterFromAggregate() async throws {
        let cloud = ScoutDBTesting.InMemoryDatabase()
        let database = probedDatabase(cloud: cloud)

        let hour = TestDate.reference.addingTimeInterval(10 * .hour)
        try await database.write(record: makeMeterRecord(id: "g-1", name: "queue_depth", value: 5, date: hour))

        for (id, category) in [("r-1", "recorder"), ("t-1", "timer"), ("f-1", "floating_counter")] {
            var other = makeMeterRecord(id: id, name: "queue_depth", value: 1, date: hour)
            other["category"] = category
            try await database.write(record: other)
        }

        _ = try await database.metricSeries(matching: meters)
        cloud.resetRequests()

        let series = try await database.metricSeries(matching: meters)

        #expect(series.map { $0.points.map(\.value) } == [[5]])
        #expect(cloud.requests[.query] == 0)
    }

    @Test("A named meter reads only its own group")
    func namedMeterReadsOneGroup() async throws {
        let alone = try await queueDepthReads(besides: [])
        let crowded = try await queueDepthReads(besides: ["cache_size", "pool_size", "backlog", "inflight"])

        #expect(crowded == alone)
    }

    @Test(
        "The peak aggregate matches a full scan of the records",
        arguments: [
            MetricSeriesQuery(category: "meter", values: .double, bucket: .hour, reduce: .last, range: window),
            MetricSeriesQuery(category: "meter", values: .double, bucket: .day, reduce: .last, range: window),
            MetricSeriesQuery(name: "queue_depth", bucket: .hour, reduce: .last, range: window),
            MetricSeriesQuery(name: "retries", category: "timer", values: .int, bucket: .hour, reduce: .last, range: window),
            MetricSeriesQuery(bucket: .hour, reduce: .last, range: window),
            MetricSeriesQuery(category: "missing", bucket: .hour, reduce: .last, range: window),
        ]
    )
    func aggregateMatchesFullScan(query: MetricSeriesQuery) async throws {
        let base = TestDate.reference.addingTimeInterval(10 * .hour)
        let rows: [(name: String, category: String?, value: Double, minutes: Double)] = [
            ("queue_depth", "meter", 8, 1),
            ("queue_depth", "meter", 5, 2),
            ("queue_depth", "meter", 3, 70),
            ("queue_depth", "meter", 4, 26 * 60),
            ("cache_size", "meter", 11, 3),
            ("queue_depth", "recorder", 100, 4),
            ("queue_depth", "timer", 0.5, 5),
            ("queue_depth", nil, 9, 6),
            ("latency", "recorder", 1.5, 7),
        ]

        for (index, row) in rows.enumerated() {
            var record = makeMeterRecord(id: "d-\(index)", name: row.name, value: row.value, date: base.addingTimeInterval(row.minutes * 60))
            record["category"] = row.category
            try await database.write(record: record)
        }

        for (index, value) in [4, 6, 2].enumerated() {
            var record = Record(recordType: IntMetricsEntry.recordType, recordID: "i-\(index)")
            record["name"] = "retries"
            record["category"] = index == 2 ? "counter" : "timer"
            record["value"] = value
            record["date"] = base.addingTimeInterval(Double(index + 1) * 60)
            record["session_id"] = "session-1"
            try await database.write(record: record)
        }

        let filtered = try await database.metricSeries(matching: query)
        let full = try await fullScan(query: query)

        #expect(filtered.map(SeriesSnapshot.init) == full.map(SeriesSnapshot.init))
    }

    private func fullScan(query: MetricSeriesQuery) async throws -> [MetricSeries] {
        let store = try await database.resolve()
        let entities: [MetricSeriesQuery.Values] = query.values.map { [$0] } ?? [.int, .double]

        var series: [MetricSeries] = []

        for values in entities {
            let records = try await store.records(
                entity: values.metricsEntity,
                dateField: "date",
                fields: ["date", "name", "category", "value"],
                in: query.bucket.start(of: query.range.lowerBound)..<query.range.upperBound
            )

            var peaks = SeriesPeaks()

            for record in records {
                let date: Date? = record["date"]
                let name: String? = record["name"]
                guard let date, let name, let key = query.key(metric: name, category: record["category"]) else {
                    continue
                }

                switch record.values["value"] {
                case .double(let raw):
                    peaks.add(raw, key: key, start: query.bucket.start(of: date))
                case .int(let raw):
                    peaks.add(Double(raw), key: key, start: query.bucket.start(of: date))
                default:
                    continue
                }
            }

            series += peaks.series
        }

        return series.sorted { $0.key < $1.key }
    }

    private func queueDepthReads(besides names: [String]) async throws -> Int {
        let cloud = ScoutDBTesting.InMemoryDatabase()
        let database = probedDatabase(cloud: cloud)
        let hour = TestDate.reference.addingTimeInterval(10 * .hour)

        for (index, name) in (["queue_depth"] + names).enumerated() {
            try await database.write(record: makeMeterRecord(id: "g-\(index)", name: name, value: 1, date: hour))
        }

        let query = MetricSeriesQuery(name: "queue_depth", category: "meter", values: .double, bucket: .hour, reduce: .last, range: range)
        _ = try await database.metricSeries(matching: query)
        cloud.resetRequests()

        let series = try await database.metricSeries(matching: query)

        #expect(series.map(\.name) == ["queue_depth"])
        return cloud.requests.records
    }

    private var meters: MetricSeriesQuery {
        MetricSeriesQuery(
            category: "meter",
            values: .double,
            bucket: .hour,
            reduce: .last,
            range: range
        )
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

struct SeriesSnapshot: Equatable {
    let key: SeriesKey
    let points: [Date: Double]

    init(series: MetricSeries) {
        key = series.key
        points = Dictionary(uniqueKeysWithValues: series.points.map { ($0.date, $0.value) })
    }
}
