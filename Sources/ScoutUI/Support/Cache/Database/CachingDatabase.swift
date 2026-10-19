//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct CachingDatabase: Sendable {
    let base: any Database
    let scope: String
    let cache: RecordCache
    let now: @Sendable () -> Date
    let types: Set<String>
}

extension CachingDatabase {
    func cachedSpan(for fingerprint: String, in frozen: Range<Date>) async -> CoveredSpan? {
        guard let covered = await cache.coveredRange(for: fingerprint) else {
            return nil
        }
        guard covered.lowerBound <= frozen.lowerBound, covered.upperBound > frozen.lowerBound else {
            return nil
        }

        let upper = min(covered.upperBound, frozen.upperBound)

        guard let records = await cache.records(for: fingerprint, in: frozen.lowerBound..<upper) else {
            return nil
        }

        return CoveredSpan(records: records, upper: upper)
    }
}

struct CoveredSpan {
    let records: [Record]
    let upper: Date
}
