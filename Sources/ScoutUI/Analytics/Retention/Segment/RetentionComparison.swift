//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

struct RetentionComparison: Equatable {
    static let day = 7
    static let tolerance = 0.02

    let delta: Double

    init?(segment: RetentionSegment, cohort: RetentionCohort) {
        guard let mine = RetentionCohort.rate(segment.retention, onDay: Self.day), let all = RetentionCohort.rate(cohort.retention, onDay: Self.day) else {
            return nil
        }
        guard cohort.size > segment.size else {
            return nil
        }

        let others = (all * Double(cohort.size) - mine * Double(segment.size)) / Double(cohort.size - segment.size)
        guard others > 0 else {
            return nil
        }
        delta = mine / others - 1
    }

    var text: String {
        guard abs(delta) > Self.tolerance else {
            return "Day \(Self.day) retention tracks the rest of the cohort"
        }
        let direction = delta > 0 ? "above" : "below"
        return "Day \(Self.day) retention runs \(abs(delta).formatted(.retentionRate)) \(direction) the rest of the cohort"
    }
}
