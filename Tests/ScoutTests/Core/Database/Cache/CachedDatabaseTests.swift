//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftData
import Testing

@testable import Scout

struct CachedDatabaseTests {
    let lower = Date(timeIntervalSince1970: 0)
    let cutoff = Date(timeIntervalSince1970: 3_000_000)
    let upper = Date(timeIntervalSince1970: 4_000_000)

    @available(iOS 17, macOS 14, *)
    func makeDatabase(base: SpyDatabase) throws -> CachedDatabase {
        let schema = Schema([CachedRecord.self, CachedSpan.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let frozen = cutoff

        return CachedDatabase(
            base: base,
            scope: "test",
            cache: RecordCache(modelContainer: container),
            settledCutoff: { frozen }
        )
    }

    func makeQuery(in range: Range<Date>) -> RecordQuery {
        RecordQuery(
            recordType: GridMatrix<Int>.self,
            filters: range.dateFilters + [RecordQuery.Filter(field: "name", op: .equals, value: .string("Session"))]
        )
    }

    func makeRecord(date: Date) -> Record {
        var record = Record(recordType: GridMatrix<Int>.recordType, recordID: UUID().uuidString)
        record.fields["date"] = .date(date)
        record.fields["name"] = .string("Session")
        record.fields["cell_1_00"] = .int(5)
        return record
    }

    @available(iOS 17, macOS 14, *)
    @Test("A repeated query only fetches the live remainder")
    func fetchesRemainderOnly() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        let frozen = makeRecord(date: Date(timeIntervalSince1970: 1_000_000))
        let live = makeRecord(date: Date(timeIntervalSince1970: 3_500_000))
        base.records = [frozen, live]

        let first = try await database.readAll(matching: makeQuery(in: lower..<upper), fields: nil)
        let second = try await database.readAll(matching: makeQuery(in: lower..<upper), fields: nil)

        #expect(first.map(\.recordID) == [frozen, live].map(\.recordID))
        #expect(second.map(\.recordID) == [frozen, live].map(\.recordID))
        #expect(base.queries.count == 2)

        let fullLower = RecordQuery.Filter(field: "date", op: .greaterThanOrEquals, value: .date(lower))
        let remainderLower = RecordQuery.Filter(field: "date", op: .greaterThanOrEquals, value: .date(cutoff))
        #expect(base.queries.first?.filters.contains(fullLower) == true)
        #expect(base.queries.last?.filters.contains(remainderLower) == true)
    }

    @available(iOS 17, macOS 14, *)
    @Test("A fully frozen query is served from the cache alone")
    func servesFrozenFromCache() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        base.records = [makeRecord(date: Date(timeIntervalSince1970: 1_000_000))]

        let first = try await database.readAll(matching: makeQuery(in: lower..<cutoff), fields: nil)
        let second = try await database.readAll(matching: makeQuery(in: lower..<cutoff), fields: nil)

        #expect(first.count == 1)
        #expect(first.map(\.recordID) == second.map(\.recordID))
        #expect(base.queries.count == 1)
    }

    @available(iOS 17, macOS 14, *)
    @Test("Non-matrix queries pass through unchanged")
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
        return RecordChunk(records: records.filter { $0.matches(query) }, cursor: nil)
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

    func metricSeries<T: SeriesScalar>(_ valueType: T.Type, category: String, in range: Range<Date>) async throws
        -> [MetricSeries]
    {
        seriesRanges.append(range)
        return series.compactMap { series in
            let points = series.points.filter { range.contains(Date(millisecondsSince1970: $0.date)) }
            guard points.count > 0 else { return nil }
            return MetricSeries(name: series.name, category: series.category, points: points)
        }
    }

    func write(record: Record) async throws {}
    func write(records: [Record]) async throws {}
}
