//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import XCTest

@testable import ScoutCache
@testable import ScoutCore

final class CachedMetricSeriesPerformanceTests: XCTestCase {
    func testSeriesMergePerformance() {
        let cached = CachedMetricSeries.records(from: makeSeries(keys: 120, points: 400, from: 0))
        let fetched = makeSeries(keys: 120, points: 120, from: 400)

        measure {
            _ = CachedMetricSeries.series(cached: cached, fetched: fetched)
        }
    }

    private func makeSeries(keys: Int, points: Int, from start: Int64) -> [MetricSeries] {
        (0..<keys).map { key in
            MetricSeries(
                name: "Session",
                category: nil,
                version: "1.0.\(key)",
                points: (0..<points).map { index in
                    MetricSeriesPoint(date: (start + Int64(index)) * 3_600_000, value: .int(index))
                }
            )
        }
    }
}

@available(iOS 17, macOS 14, *)
final class RecordCachePerformanceTests: XCTestCase {
    func testStorePerformance() throws {
        let cache = try makeRecordCache(CachedRecord.self)
        let records = makeRecords(count: 5_000)
        let range = Date(timeIntervalSince1970: 0)..<Date(timeIntervalSince1970: 6_000_000)

        measure {
            runBlocking { await cache.store(records, for: "fp", covering: range) }
        }
    }

    func testFetchAndDecodePerformance() throws {
        let cache = try makeRecordCache(CachedRecord.self)
        let records = makeRecords(count: 5_000)
        let range = Date(timeIntervalSince1970: 0)..<Date(timeIntervalSince1970: 6_000_000)
        runBlocking { await cache.store(records, for: "fp", covering: range) }

        measure {
            runBlocking { _ = await cache.records(for: "fp", in: range) }
        }
    }

    private func makeRecords(count: Int) -> [Record] {
        (0..<count).map { index in
            var record = Record(recordType: "MetricSeriesPoint", recordID: UUID().uuidString)
            record.fields["date"] = .date(Date(timeIntervalSince1970: TimeInterval(index) * 1_000))
            record.fields["name"] = .string("Session")
            record.fields["value"] = .int(Int64(index))
            return record
        }
    }
}

@available(iOS 17, macOS 14, *)
final class CachedDatabasePerformanceTests: XCTestCase {
    func testCachedSeriesReadPerformance() throws {
        let base = SpyDatabase()
        base.series = makeSeries(versions: 40, points: 800)
        let cutoff = Date(timeIntervalSince1970: 3_000_000)
        let database = CachedDatabase(
            base: base,
            scope: "perf",
            cache: try makeRecordCache(CachedRecord.self),
            settledCutoff: { cutoff }
        )
        let query = SeriesQuery(
            name: "Session",
            byVersion: true,
            range: Date(timeIntervalSince1970: 0)..<Date(timeIntervalSince1970: 4_000_000)
        )

        runBlocking { _ = try? await database.series(matching: query) }

        measure {
            runBlocking { _ = try? await database.series(matching: query) }
        }
    }

    private func makeSeries(versions: Int, points: Int) -> [MetricSeries] {
        (0..<versions).map { version in
            MetricSeries(
                name: "Session",
                category: nil,
                version: "1.0.\(version)",
                points: (0..<points).map { index in
                    MetricSeriesPoint(date: Int64(index) * 3_600 * 1_000, value: .int(index))
                }
            )
        }
    }
}

extension XCTestCase {
    fileprivate func runBlocking(timeout: TimeInterval = 60, _ operation: @escaping @Sendable () async -> Void) {
        let finished = expectation(description: "async operation")
        Task {
            await operation()
            finished.fulfill()
        }
        wait(for: [finished], timeout: timeout)
    }
}
