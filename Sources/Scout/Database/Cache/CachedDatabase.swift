//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct CachedDatabase: Database {
    @MainActor package static var cache: (any RecordCaching)?

    let base: any Database
    let scope: String
    let cache: any RecordCaching
    let settledCutoff: @Sendable () -> Date

    package init(base: any Database, scope: String, cache: any RecordCaching, settledCutoff: @escaping @Sendable () -> Date = { Date().startOfWeek.addingWeek(-1) }) {
        self.base = base
        self.scope = scope
        self.cache = cache
        self.settledCutoff = settledCutoff
    }

    package func lookup(recordName: String, fields: [String]?) async throws -> Record {
        let fingerprint = CacheKey.lookup(scope: scope, recordName: recordName, fields: fields).fingerprint

        if let record = await cache.lookupRecord(for: fingerprint) {
            return record
        }

        let record = try await base.lookup(
            recordName: recordName,
            fields: fields
        )

        if record.recordType == EventEntry.recordType {
            await cache.storeLookup(record, for: fingerprint)
        }

        return record
    }

    package func series(matching query: SeriesQuery) async throws -> [MetricSeries] {
        let frozenUpper = min(query.range.upperBound, settledCutoff())

        guard query.range.lowerBound < frozenUpper else {
            return try await base.series(matching: query)
        }

        let fingerprint = CacheKey.series(scope: scope, query: query).fingerprint

        var cached: [Record] = []
        var cachedUpper = query.range.lowerBound

        if let covered = await cache.coveredRange(for: fingerprint), covered.lowerBound <= query.range.lowerBound, covered.upperBound > query.range.lowerBound {
            let upper = min(covered.upperBound, frozenUpper)

            if let records = await cache.records(for: fingerprint, in: query.range.lowerBound..<upper) {
                cached = records
                cachedUpper = upper
            }
        }

        guard cachedUpper < query.range.upperBound else {
            return CachedMetricSeries.series(cached: cached, fetched: [])
        }

        var remainder = query
        remainder.range = cachedUpper..<query.range.upperBound
        let fetched = try await base.series(matching: remainder)

        if cachedUpper < frozenUpper {
            await cache.store(
                CachedMetricSeries.records(from: fetched),
                for: fingerprint,
                covering: cachedUpper..<frozenUpper
            )
        }

        return CachedMetricSeries.series(cached: cached, fetched: fetched)
    }
}
