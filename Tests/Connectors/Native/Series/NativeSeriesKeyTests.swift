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
    @Test("A named metric in a category reads only its own group")
    func namedMetricReadsOneGroup() async throws {
        let alone = try await latencyReads(besides: [])
        let crowded = try await latencyReads(besides: ["render", "decode", "upload", "parse"])

        #expect(crowded == alone)
    }

    @Test(
        "A keyed sum matches the full sum it narrows",
        arguments: [
            MetricSeriesQuery(name: "latency", category: "timer", bucket: .hour, range: window),
            MetricSeriesQuery(name: "latency", category: "timer", values: .int, bucket: .day, range: window),
            MetricSeriesQuery(name: "re|new", category: "billing|eu", bucket: .hour, range: window),
            MetricSeriesQuery(name: "latency", category: "", bucket: .hour, range: window),
            MetricSeriesQuery(name: "latency", bucket: .hour, range: window),
            MetricSeriesQuery(category: "timer", bucket: .hour, range: window),
            MetricSeriesQuery(name: "missing", category: "timer", bucket: .hour, range: window),
        ]
    )
    func keyedSumMatchesFullSum(query: MetricSeriesQuery) async throws {
        let base = TestDate.reference.addingTimeInterval(10 * .hour)
        let rows: [(name: String, category: String?, value: Double, hours: Double)] = [
            ("latency", "timer", 3, 0),
            ("latency", "timer", 4, 1),
            ("latency", "timer", 5, 26),
            ("render", "timer", 7, 0),
            ("latency", "recorder", 11, 0),
            ("latency", nil, 13, 0),
            ("re|new", "billing|eu", 2.5, 0),
            ("re", "new|billing|eu", 17, 0),
        ]

        for (index, row) in rows.enumerated() {
            var record = makeMetricRecord(id: "m-\(index)", name: row.name, value: Int64(row.value))
            record["category"] = row.category
            record["date"] = base.addingTimeInterval(row.hours * .hour)
            try await database.write(record: record)

            var double = makeMeterRecord(id: "d-\(index)", name: row.name, value: row.value, date: base.addingTimeInterval(row.hours * .hour))
            double["category"] = row.category
            try await database.write(record: double)
        }

        var unkeyed = query
        unkeyed.name = nil
        unkeyed.category = nil

        let keyed = try await database.metricSeries(matching: query)
        let full = try await database.metricSeries(matching: unkeyed).filter {
            query.key(metric: $0.name, category: $0.category ?? "") != nil
        }

        #expect(keyed.map(SeriesSnapshot.init) == full.map(SeriesSnapshot.init))
    }

    private func latencyReads(besides names: [String]) async throws -> Int {
        let cloud = ScoutDBTesting.InMemoryDatabase()
        let database = probedDatabase(cloud: cloud)

        for (index, name) in (["latency"] + names).enumerated() {
            try await database.write(record: makeMetricRecord(id: "m-\(index)", name: name, value: 1))
        }

        let query = MetricSeriesQuery(name: "latency", category: "timer", values: .int, bucket: .hour, range: window)
        _ = try await database.metricSeries(matching: query)
        cloud.resetRequests()

        let series = try await database.metricSeries(matching: query)

        #expect(series.map(\.name) == ["latency"])
        return cloud.requests.records
    }
}
