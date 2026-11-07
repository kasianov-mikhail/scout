//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension RetentionCohort {
    static func rate(retention: [Double?], onDay day: Int) -> Double? {
        guard let index = dayOffsets.firstIndex(of: day), retention.indices.contains(index) else {
            return nil
        }
        return retention[index]
    }

    func kept(onDay day: RetentionDay) -> Int? {
        guard let rate = Self.rate(retention: retention, onDay: day.rawValue) else {
            return nil
        }
        return rate.kept(in: size)
    }
}

extension [RetentionCohort] {
    var recent: [RetentionCohort] {
        Array(sorted(by: >).prefix(8))
    }

    var matured: [RetentionCohort] {
        filter { RetentionCohort.rate(retention: $0.retention, onDay: RetentionDay.day7.rawValue) != nil }
    }

    func average(onDay day: Int) -> Double? {
        var kept = 0.0
        var installs = 0

        for cohort in self {
            guard let rate = RetentionCohort.rate(retention: cohort.retention, onDay: day) else {
                continue
            }
            kept += rate * Double(cohort.size)
            installs += cohort.size
        }

        guard installs > 0 else {
            return nil
        }
        return kept / Double(installs)
    }
}

extension Double {
    func kept(in size: Int) -> Int {
        Int((self * Double(size)).rounded())
    }
}
