//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftData
import Testing

@testable import Cache
@testable import Scout

struct CachedDatabaseTests {
    let lower = Date(timeIntervalSince1970: 0)
    let cutoff = Date(timeIntervalSince1970: 3_000_000)
    let upper = Date(timeIntervalSince1970: 4_000_000)

    @available(iOS 17, macOS 14, *)
    func makeDatabase(base: SpyDatabase) throws -> CachedDatabase {
        try makeDatabase(base: base, row: CachedRecord.self)
    }

    @available(iOS 17, macOS 14, *)
    func makeDatabase<Row: CacheRow>(base: SpyDatabase, row: Row.Type) throws -> CachedDatabase {
        let frozen = cutoff

        return CachedDatabase(
            base: base,
            scope: "test",
            cache: try makeRecordCache(row),
            settledCutoff: { frozen }
        )
    }

    @available(iOS 17, macOS 14, *)
    @Test("Record queries pass through unchanged")
    func passesThroughOtherQueries() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        let query = RecordQuery(
            recordType: Event.self,
            filters: (lower..<upper).dateFilters,
            sort: [RecordQuery.Sort(field: "date", ascending: false)]
        )

        _ = try await database.readAll(matching: query, fields: nil)
        _ = try await database.readAll(matching: query, fields: nil)

        #expect(base.queries.count == 2)
        #expect(base.queries.first?.filters == query.filters)
    }

    @available(iOS 17, macOS 14, *)
    @Test("A repeated series request only fetches the live remainder")
    func seriesFetchesRemainderOnly() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        base.series = [
            MetricSeries(
                name: "2xx",
                category: "http_status",
                points: [
                    MetricSeriesPoint(date: 1_000_000_000, value: .int(4)),
                    MetricSeriesPoint(date: 3_500_000_000, value: .int(7)),
                ]
            )
        ]

        let first = try await database.metricSeries(Int.self, category: "http_status", in: lower..<upper)
        let second = try await database.metricSeries(Int.self, category: "http_status", in: lower..<upper)

        #expect(base.seriesRanges == [lower..<upper, cutoff..<upper])
        #expect(first.count == 1)
        #expect(second.count == 1)
        #expect(second.first?.name == "2xx")
        #expect(second.first?.category == "http_status")
        #expect(second.first?.points.map(\.date) == first.first?.points.map(\.date))
        #expect(second.first?.points.map(\.value) == [.int(4), .int(7)])
    }

    @available(iOS 17, macOS 14, *)
    @Test("Series caches are split by scalar type and category")
    func seriesSeparatesFingerprints() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        base.series = [
            MetricSeries(
                name: "latency",
                category: "http_latency",
                points: [MetricSeriesPoint(date: 1_000_000_000, value: .double(0.2))]
            )
        ]

        _ = try await database.metricSeries(Double.self, category: "http_latency", in: lower..<upper)
        _ = try await database.metricSeries(Int.self, category: "http_status", in: lower..<upper)

        #expect(base.seriesRanges == [lower..<upper, lower..<upper])
    }

    @available(iOS 17, macOS 14, *)
    @Test("Version-grouped series round-trip through the cache")
    func cachesVersionGroups() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        base.series = [
            MetricSeries(
                name: "Session",
                category: nil,
                version: "1.2.0",
                points: [MetricSeriesPoint(date: 1_000_000_000, value: .int(4))]
            )
        ]
        let query = SeriesQuery(name: "Session", byVersion: true, range: lower..<upper)

        let first = try await database.series(matching: query)
        let second = try await database.series(matching: query)

        #expect(base.seriesRanges == [lower..<upper, cutoff..<upper])
        #expect(first.map(\.version) == ["1.2.0"])
        #expect(second.map(\.version) == ["1.2.0"])
        #expect(second.first?.points.map(\.value) == [.int(4)])
    }

    @available(iOS 18, macOS 15, *)
    @Test("A repeated series request hits the indexed cache")
    func seriesRoundTripsThroughIndexedRows() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base, row: IndexedCachedRecord.self)
        base.series = [
            MetricSeries(
                name: "2xx",
                category: "http_status",
                points: [
                    MetricSeriesPoint(date: 1_000_000_000, value: .int(4)),
                    MetricSeriesPoint(date: 3_500_000_000, value: .int(7)),
                ]
            )
        ]

        let first = try await database.metricSeries(Int.self, category: "http_status", in: lower..<upper)
        let second = try await database.metricSeries(Int.self, category: "http_status", in: lower..<upper)

        #expect(base.seriesRanges == [lower..<upper, cutoff..<upper])
        #expect(second.first?.points.map(\.date) == first.first?.points.map(\.date))
        #expect(second.first?.points.map(\.value) == [.int(4), .int(7)])
    }

    @available(iOS 17, macOS 14, *)
    @Test("An event lookup is served from the cache after the first fetch")
    func cachesEventLookup() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        var event = Record(recordType: EventEntry.recordType, recordID: "event-1")
        event.fields["params"] = .bytes(Data("payload".utf8))
        base.records = [event]

        let first = try await database.lookup(recordName: "event-1", fields: ["params"])
        let second = try await database.lookup(recordName: "event-1", fields: ["params"])

        #expect(first.fields == second.fields)
        #expect(second.recordType == EventEntry.recordType)
        #expect(base.lookups == ["event-1"])
    }

    @available(iOS 17, macOS 14, *)
    @Test("Lookups of mutable record types are not cached")
    func skipsMutableLookup() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        base.records = [Record(recordType: SessionEntry.recordType, recordID: "session-1")]

        _ = try await database.lookup(recordName: "session-1", fields: nil)
        _ = try await database.lookup(recordName: "session-1", fields: nil)

        #expect(base.lookups == ["session-1", "session-1"])
    }

    @available(iOS 17, macOS 14, *)
    @Test("Lookups with different field sets are cached separately")
    func separatesLookupFields() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        base.records = [Record(recordType: EventEntry.recordType, recordID: "event-1")]

        _ = try await database.lookup(recordName: "event-1", fields: ["params"])
        _ = try await database.lookup(recordName: "event-1", fields: nil)
        _ = try await database.lookup(recordName: "event-1", fields: nil)

        #expect(base.lookups == ["event-1", "event-1"])
    }
}

final class SpyDatabase: Database, @unchecked Sendable {
    var records: [Record] = []
    var queries: [RecordQuery] = []
    var lookups: [String] = []
    var series: [MetricSeries] = []
    var seriesRanges: [Range<Date>] = []

    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        queries.append(query)
        // The cache never caches reads, so these tests only assert on the recorded
        // queries — the spy echoes back whatever rows it was seeded with, unfiltered.
        return RecordChunk(records: records, cursor: nil)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        lookups.append(recordName)
        guard let record = records.first(where: { $0.recordID == recordName }) else {
            throw RecordNotFoundError()
        }
        return record
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        []
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        []
    }

    func series(matching query: SeriesQuery) async throws -> [MetricSeries] {
        seriesRanges.append(query.range)
        return series.compactMap { series in
            let points = series.points.filter { query.range.contains(Date(millisecondsSince1970: $0.date)) }
            guard points.count > 0 else { return nil }
            return MetricSeries(name: series.name, category: series.category, version: series.version, points: points)
        }
    }

    func write(record: Record) async throws {}
    func write(records: [Record]) async throws {}
}
