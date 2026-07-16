//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@available(iOS 17, macOS 14, *)
struct CachedDatabase: Database {
    let base: any Database
    let scope: String
    let cache: RecordCache

    // Matrices are keyed by start of week, and late uploads from offline devices can still
    // mutate recently closed weeks, so only weeks that ended over a week ago are frozen.
    var settledCutoff: @Sendable () -> Date = { Date().startOfWeek.addingWeek(-1) }

    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        guard fields == nil, let plan = CachedQuery(query: query, scope: scope, cutoff: settledCutoff()) else {
            return try await base.read(matching: query, fields: fields)
        }

        var cachedUpper = await cachedUpper(for: plan.fingerprint, in: plan.range, frozenUpper: plan.frozenUpper)

        var cached: [Record] = []
        if cachedUpper > plan.range.lowerBound {
            if let records = await cache.records(for: plan.fingerprint, in: plan.range.lowerBound..<cachedUpper) {
                cached = records
            } else {
                cachedUpper = plan.range.lowerBound
            }
        }

        guard cachedUpper < plan.range.upperBound else {
            return RecordChunk(records: cached, cursor: nil)
        }

        let remainder = cachedUpper..<plan.range.upperBound
        let fetched = try await base.readAll(matching: plan.query(in: remainder), fields: nil)

        if remainder.lowerBound < plan.frozenUpper {
            await cache.store(fetched, for: plan.fingerprint, covering: remainder.lowerBound..<plan.frozenUpper)
        }
        return RecordChunk(records: cached + fetched, cursor: nil)
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        try await base.read(matching: query, fields: fields, limit: limit)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        let fieldsKey = fields.map { $0.sorted().joined(separator: ",") } ?? "*"
        let fingerprint = [scope, "lookup", recordName, fieldsKey].joined(separator: "|")

        if let record = await cache.lookupRecord(for: fingerprint) {
            return record
        }
        let record = try await base.lookup(recordName: recordName, fields: fields)
        if cachedLookupTypes.contains(record.recordType) {
            await cache.storeLookup(record, for: fingerprint)
        }
        return record
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        try await base.activity(in: range)
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        try await base.retention(in: range)
    }

    func metricSeries<T: SeriesScalar>(_ valueType: T.Type, category: String, in range: Range<Date>) async throws
        -> [MetricSeries]
    {
        let frozenUpper = min(range.upperBound, settledCutoff())
        guard range.lowerBound < frozenUpper else {
            return try await base.metricSeries(valueType, category: category, in: range)
        }

        let fingerprint = CachedMetricSeries.fingerprint(scope: scope, values: T.seriesValues, category: category)
        var cachedUpper = await cachedUpper(for: fingerprint, in: range, frozenUpper: frozenUpper)

        var cached: [Record] = []
        if cachedUpper > range.lowerBound {
            if let records = await cache.records(for: fingerprint, in: range.lowerBound..<cachedUpper) {
                cached = records
            } else {
                cachedUpper = range.lowerBound
            }
        }

        var fetched: [MetricSeries] = []
        if cachedUpper < range.upperBound {
            fetched = try await base.metricSeries(valueType, category: category, in: cachedUpper..<range.upperBound)

            if cachedUpper < frozenUpper {
                let records = CachedMetricSeries.records(from: fetched)
                await cache.store(records, for: fingerprint, covering: cachedUpper..<frozenUpper)
            }
        }
        return CachedMetricSeries.series(cached: cached, fetched: fetched)
    }

    private func cachedUpper(for fingerprint: String, in range: Range<Date>, frozenUpper: Date) async -> Date {
        guard let covered = await cache.coveredRange(for: fingerprint),
            covered.lowerBound <= range.lowerBound, covered.upperBound > range.lowerBound
        else {
            return range.lowerBound
        }
        return min(covered.upperBound, frozenUpper)
    }

    func write(record: Record) async throws {
        try await base.write(record: record)
    }

    func write(records: [Record]) async throws {
        try await base.write(records: records)
    }
}

private let cachedLookupTypes: Set<String> = [EventEntry.recordType]

extension Backend {
    @MainActor var cachedDatabase: any Database {
        if #available(iOS 17, macOS 14, *) {
            return DatabaseCacheRegistry.database(for: self)
        }
        return database
    }
}

@available(iOS 17, macOS 14, *)
@MainActor
enum DatabaseCacheRegistry {
    private static var databases: [String: any Database] = [:]
    private static var cache: RecordCache??

    static func database(for backend: Backend) -> any Database {
        if let database = databases[backend.id] {
            return database
        }
        let database: any Database =
            if let cache = sharedCache() {
                CachedDatabase(base: backend.database, scope: backend.id, cache: cache)
            } else {
                backend.database
            }
        databases[backend.id] = database
        return database
    }

    private static func sharedCache() -> RecordCache? {
        if let cache {
            return cache
        }
        let created = RecordCacheStore.container().map { RecordCache(modelContainer: $0) }
        cache = .some(created)
        return created
    }
}
