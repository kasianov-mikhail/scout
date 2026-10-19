//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension CachingDatabase: AudienceReader {
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        let lower = range.lowerBound.startOfDay
        let frozenUpper = min(range.upperBound, now().startOfWeek.addingWeek(-1))

        guard lower < frozenUpper else {
            return try await base.activity(in: range)
        }

        let fingerprint = [scope, "activity"].joined(separator: "|")
        let cached = await cachedSpan(for: fingerprint, in: lower..<frozenUpper)
        let cachedUpper = cached?.upper ?? lower
        let points = cached?.records.compactMap(ActivityPoint.init(record:)) ?? []

        guard cachedUpper < range.upperBound else {
            return points
        }

        let fetched = try await base.activity(in: cachedUpper..<range.upperBound)

        if cachedUpper < frozenUpper {
            await cache.store(fetched.map(\.record), for: fingerprint, covering: cachedUpper..<frozenUpper)
        }

        return points + fetched
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        try await base.retention(in: range)
    }
}

extension ActivityPoint {
    fileprivate init?(record: Record) {
        let date: Date? = record["date"]
        let dau: Int? = record["dau"]
        let wau: Int? = record["wau"]
        let mau: Int? = record["mau"]

        guard let date, let dau, let wau, let mau else {
            return nil
        }

        self.init(date: date.millisecondsSince1970, dau: dau, wau: wau, mau: mau)
    }

    fileprivate var record: Record {
        var record = Record(recordType: "ActivityPoint", recordID: UUID().uuidString)
        record["date"] = Date(millisecondsSince1970: date)
        record["dau"] = dau
        record["wau"] = wau
        record["mau"] = mau
        return record
    }
}
