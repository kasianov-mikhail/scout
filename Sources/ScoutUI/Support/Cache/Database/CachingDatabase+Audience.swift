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

        return try await cached(name: "activity", range: lower..<range.upperBound, frozenUpper: frozenUpper, fetch: base.activity)
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        let lower = range.lowerBound.startOfWeek
        let horizon = TimeInterval((RetentionCohort.dayOffsets.last ?? 0) + 1) * .day
        let frozenUpper = min(range.upperBound, now().startOfWeek.addingWeek(-1).addingTimeInterval(-horizon).startOfWeek)

        guard lower < frozenUpper else {
            return try await base.retention(in: lower..<range.upperBound)
        }

        let cohorts = try await cached(name: "retention", range: lower..<range.upperBound, frozenUpper: frozenUpper) { chunk in
            try await base.retention(in: chunk.lowerBound..<min(chunk.upperBound.addingTimeInterval(horizon), range.upperBound)).filter { chunk.contains($0.id) }
        }

        return cohorts.sorted()
    }
}
