//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@available(iOS 17, macOS 14, *)
struct CachedDatabase: Database {
    let base: any Database
    let scope: String
    let cache: any RecordCaching

    var settledCutoff: @Sendable () -> Date = {
        Date().startOfWeek.addingWeek(-1)
    }

    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        try await base.read(matching: query, fields: fields)
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
        if CachedLookupTypes.all.contains(record.recordType) {
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

    func series(matching query: SeriesQuery) async throws -> [MetricSeries] {
        let frozenUpper = min(query.range.upperBound, settledCutoff())
        guard query.range.lowerBound < frozenUpper else {
            return try await base.series(matching: query)
        }

        let fingerprint = CachedMetricSeries.fingerprint(scope: scope, query: query)
        var cachedUpper = await cachedUpper(for: fingerprint, in: query.range, frozenUpper: frozenUpper)

        var cached: [Record] = []
        if cachedUpper > query.range.lowerBound {
            if let records = await cache.records(for: fingerprint, in: query.range.lowerBound..<cachedUpper) {
                cached = records
            } else {
                cachedUpper = query.range.lowerBound
            }
        }

        var fetched: [MetricSeries] = []
        if cachedUpper < query.range.upperBound {
            var remainder = query
            remainder.range = cachedUpper..<query.range.upperBound
            fetched = try await base.series(matching: remainder)

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
