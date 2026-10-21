//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

struct CachingDatabaseTests {
    let lower = Date(timeIntervalSince1970: 0)
    let upper = Date(timeIntervalSince1970: 4_000_000)

    var cutoff: Date {
        upper.startOfWeek.addingWeek(-1)
    }

    func makeDatabase(base: SpyDatabase, types: Set<String> = [Event.recordType], now: Date? = nil) throws -> CachingDatabase {
        let now = now ?? upper

        return CachingDatabase(
            base: base,
            scope: "test",
            cache: try makeRecordCache(),
            now: { now },
            types: types
        )
    }

    @Test("Writes reach the wrapped database untouched")
    func forwardsWrites() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        let first = Record(recordType: "Event", recordID: "event-1")
        let second = Record(recordType: "Event", recordID: "event-2")

        try await database.write(record: first)
        try await database.write(records: [second])

        #expect(base.written.map(\.recordID) == ["event-1", "event-2"])
    }

    @Test("Record queries pass through unchanged")
    func passesThroughOtherQueries() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        let query = RecordQuery(
            recordType: Event.self,
            filters: [
                RecordQuery.Filter(field: "date", op: .greaterThanOrEquals, value: .date(lower)),
                RecordQuery.Filter(field: "date", op: .lessThan, value: .date(upper)),
            ],
            sort: [RecordQuery.Sort(field: "date", ascending: false)]
        )

        _ = try await database.read(matching: query, fields: nil)
        _ = try await database.read(matching: query, fields: nil)

        #expect(base.queries.count == 2)
        #expect(base.queries.first?.filters == query.filters)
    }

    @Test("A repeated series request only fetches the live remainder")
    func seriesFetchesRemainderOnly() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        base.series = [
            MetricSeries(
                name: "2xx",
                category: "http_status",
                points: [
                    MetricSeriesPoint(date: Date(millisecondsSince1970: 1_000_000_000), value: 4),
                    MetricSeriesPoint(date: Date(millisecondsSince1970: 3_500_000_000), value: 7),
                ]
            )
        ]

        let query = MetricSeriesQuery(
            category: "http_status",
            values: .int,
            bucket: .hour,
            range: lower..<upper
        )
        let first = try await database.metricSeries(matching: query)
        let second = try await database.metricSeries(matching: query)

        #expect(base.seriesRanges == [lower..<upper, cutoff..<upper])
        #expect(first.count == 1)
        #expect(second.count == 1)
        #expect(second.first?.name == "2xx")
        #expect(second.first?.category == "http_status")
        #expect(second.first?.points.map(\.date) == first.first?.points.map(\.date))
        #expect(second.first?.points.map(\.value) == [4, 7])
    }

    @Test("A repeated activity request reads closed days from the cache and fetches the rest")
    func activityFetchesRemainderOnly() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        let early = lower.addingTimeInterval(.day)
        let late = cutoff.addingTimeInterval(.day)
        base.points = [
            ActivityPoint(date: early.millisecondsSince1970, dau: 3, wau: 5, mau: 8),
            ActivityPoint(date: late.millisecondsSince1970, dau: 2, wau: 4, mau: 9),
        ]

        let first = try await database.activity(in: lower..<upper)
        let second = try await database.activity(in: lower..<upper)

        #expect(base.activityRanges == [lower..<upper, cutoff..<upper])
        #expect(first.map(\.date) == [early.millisecondsSince1970, late.millisecondsSince1970])
        #expect(second.map(\.date) == first.map(\.date))
        #expect(second.map(\.mau) == [8, 9])
    }

    @Test("A repeated retention request reads closed cohorts from the cache and fetches the rest from a week start")
    func retentionFetchesRemainderOnly() async throws {
        let base = SpyDatabase()
        let now = Date(timeIntervalSince1970: 10_000_000)
        let database = try makeDatabase(base: base, types: [], now: now)
        let frozenUpper = now.startOfWeek.addingWeek(-1).addingTimeInterval(-31 * .day).startOfWeek
        let closed = RetentionCohort(id: lower.startOfWeek.addingWeek(2), size: 4, retention: [1, 0.5, nil], segments: [])
        let open = RetentionCohort(id: frozenUpper.addingWeek(1), size: 2, retention: [1, nil, nil], segments: [])
        base.cohorts = [closed, open]

        let first = try await database.retention(in: lower..<now)
        let second = try await database.retention(in: lower..<now)

        #expect(base.retentionRanges == [lower.startOfWeek..<now, frozenUpper..<now])
        #expect(first == [closed, open])
        #expect(second == [closed, open])
    }

    @Test("An interrupted activity load keeps its finished quarters and the next load fetches only the rest")
    func activityResumesAfterInterruptedLoad() async throws {
        let base = SpyDatabase()
        let now = lower.addingTimeInterval(400 * .day)
        let database = try makeDatabase(base: base, now: now)
        let quarters = (0...4).map { lower.addingWeek(13 * $0) }
        base.points = quarters.map { ActivityPoint(date: $0.addingTimeInterval(.day).millisecondsSince1970, dau: 1, wau: 2, mau: 3) }
        base.callsBeforeFailure = 2

        await #expect(throws: CancellationError.self) {
            try await database.activity(in: lower..<now)
        }

        base.callsBeforeFailure = .max
        let resumed = try await database.activity(in: lower..<now)
        let warm = try await database.activity(in: lower..<now)

        #expect(
            base.activityRanges == [
                quarters[0]..<quarters[1],
                quarters[1]..<quarters[2],
                quarters[2]..<quarters[3],
                quarters[2]..<quarters[3],
                quarters[3]..<quarters[4],
                quarters[4]..<now,
                now.startOfWeek.addingWeek(-1)..<now,
            ]
        )
        #expect(resumed.map(\.date) == base.points.map(\.date))
        #expect(warm.map(\.date) == base.points.map(\.date))
    }

    @Test("A retention load reads each quarter with the retention horizon and keeps only that quarter's cohorts")
    func retentionResumesAfterInterruptedLoad() async throws {
        let base = SpyDatabase()
        let now = lower.addingTimeInterval(400 * .day)
        let database = try makeDatabase(base: base, now: now)
        let start = lower.startOfWeek
        let horizon = 31 * TimeInterval.day
        let quarters = (0...4).map { start.addingWeek(13 * $0) }
        base.cohorts = quarters.map { RetentionCohort(id: $0, size: 1, retention: [1], segments: []) }
        base.callsBeforeFailure = 1

        await #expect(throws: CancellationError.self) {
            try await database.retention(in: lower..<now)
        }

        base.callsBeforeFailure = .max
        let resumed = try await database.retention(in: lower..<now)

        #expect(
            base.retentionRanges == [
                quarters[0]..<quarters[1].addingTimeInterval(horizon),
                quarters[1]..<quarters[2].addingTimeInterval(horizon),
                quarters[1]..<quarters[2].addingTimeInterval(horizon),
                quarters[2]..<quarters[3].addingTimeInterval(horizon),
                quarters[3]..<now,
            ]
        )
        #expect(resumed == base.cohorts)
    }

    @Test("Series caches are split by scalar type and category")
    func seriesSeparatesFingerprints() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        base.series = [
            MetricSeries(
                name: "latency",
                category: "http_latency",
                points: [MetricSeriesPoint(date: Date(millisecondsSince1970: 1_000_000_000), value: 0.2)]
            )
        ]

        _ = try await database.metricSeries(
            matching: MetricSeriesQuery(
                category: "http_latency",
                values: .double,
                bucket: .hour,
                range: lower..<upper
            )
        )
        _ = try await database.metricSeries(
            matching: MetricSeriesQuery(
                category: "http_status",
                values: .int,
                bucket: .hour,
                range: lower..<upper
            )
        )

        #expect(base.seriesRanges == [lower..<upper, lower..<upper])
    }

    @Test("Version-grouped series round-trip through the cache")
    func cachesVersionGroups() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        base.series = [
            MetricSeries(
                name: "Session",
                category: nil,
                version: "1.2.0",
                points: [MetricSeriesPoint(date: Date(millisecondsSince1970: 1_000_000_000), value: 4)]
            )
        ]
        let query = LifecycleSeriesQuery(name: Session.recordType, byVersion: true, range: lower..<upper)

        let first = try await database.lifecycleSeries(matching: query)
        let second = try await database.lifecycleSeries(matching: query)

        #expect(base.seriesRanges == [lower..<upper, cutoff..<upper])
        #expect(first.map(\.version) == ["1.2.0"])
        #expect(second.map(\.version) == ["1.2.0"])
        #expect(second.first?.points.map(\.value) == [4])
    }

    @Test("An event lookup is served from the cache after the first fetch")
    func cachesEventLookup() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        var event = Record(recordType: Event.recordType, recordID: "event-1")
        event.fields["params"] = .bytes(Data("payload".utf8))
        base.records = [event]

        let first = try await database.lookup(recordName: "event-1", fields: ["params"])
        let second = try await database.lookup(recordName: "event-1", fields: ["params"])

        #expect(first.fields == second.fields)
        #expect(second.recordType == Event.recordType)
        #expect(base.lookups == ["event-1"])
    }

    @Test("Lookups of mutable record types are not cached")
    func skipsMutableLookup() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        base.records = [Record(recordType: Session.recordType, recordID: "session-1")]

        _ = try await database.lookup(recordName: "session-1", fields: nil)
        _ = try await database.lookup(recordName: "session-1", fields: nil)

        #expect(base.lookups == ["session-1", "session-1"])
    }

    @Test("The immutable record types decide which lookups are cached")
    func honorsImmutableRecordTypes() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base, types: [Session.recordType])
        base.records = [
            Record(recordType: Session.recordType, recordID: "session-1"),
            Record(recordType: Event.recordType, recordID: "event-1"),
        ]

        _ = try await database.lookup(recordName: "session-1", fields: nil)
        _ = try await database.lookup(recordName: "session-1", fields: nil)
        _ = try await database.lookup(recordName: "event-1", fields: nil)
        _ = try await database.lookup(recordName: "event-1", fields: nil)

        #expect(base.lookups == ["session-1", "event-1", "event-1"])
    }

    @Test("Lookups with different field sets are cached separately")
    func separatesLookupFields() async throws {
        let base = SpyDatabase()
        let database = try makeDatabase(base: base)
        base.records = [Record(recordType: Event.recordType, recordID: "event-1")]

        _ = try await database.lookup(recordName: "event-1", fields: ["params"])
        _ = try await database.lookup(recordName: "event-1", fields: nil)
        _ = try await database.lookup(recordName: "event-1", fields: nil)

        #expect(base.lookups == ["event-1", "event-1"])
    }
}

final class SpyDatabase: DatabaseReader, DatabaseWriter, @unchecked Sendable {
    var records: [Record] = []
    var written: [Record] = []
    var queries: [RecordQuery] = []
    var lookups: [String] = []
    var series: [MetricSeries] = []
    var seriesRanges: [Range<Date>] = []
    var points: [ActivityPoint] = []
    var activityRanges: [Range<Date>] = []
    var cohorts: [RetentionCohort] = []
    var retentionRanges: [Range<Date>] = []
    var callsBeforeFailure = Int.max

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        queries.append(query)
        // The cache never caches reads, so these tests only assert on the recorded
        // queries — the spy echoes back whatever rows it was seeded with, unfiltered.
        return RecordChunk(records: records, cursor: nil)
    }

    func write(record: Record) async throws {
        written.append(record)
    }

    func write(records: [Record]) async throws {
        written += records
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        lookups.append(recordName)
        guard let record = records.first(where: { $0.recordID == recordName }) else {
            throw RecordNotFoundError()
        }
        return record
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        activityRanges.append(range)
        try countCall()
        return points.filter { range.lowerBound.startOfDay.millisecondsSince1970 <= $0.date && $0.date < range.upperBound.millisecondsSince1970 }
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        retentionRanges.append(range)
        try countCall()
        return cohorts.filter { range.contains($0.id) }
    }

    private func countCall() throws {
        guard callsBeforeFailure > 0 else {
            throw CancellationError()
        }
        callsBeforeFailure -= 1
    }

    func devices(in range: Range<Date>) async throws -> [DeviceActivity] {
        []
    }

    func deviceCounts(in ranges: [Range<Date>]) async throws -> [Int] {
        ranges.map { _ in 0 }
    }

    func eventSeries(matching query: EventSeriesQuery) async throws -> [MetricSeries] {
        series(in: query.range)
    }

    func lifecycleSeries(matching query: LifecycleSeriesQuery) async throws -> [MetricSeries] {
        series(in: query.range)
    }

    func metricSeries(matching query: MetricSeriesQuery) async throws -> [MetricSeries] {
        series(in: query.range)
    }

    private func series(in range: Range<Date>) -> [MetricSeries] {
        seriesRanges.append(range)
        return series.compactMap { series in
            let points = series.points.filter { range.contains($0.date) }
            guard !points.isEmpty else { return nil }
            return MetricSeries(name: series.name, category: series.category, version: series.version, points: points)
        }
    }
}
