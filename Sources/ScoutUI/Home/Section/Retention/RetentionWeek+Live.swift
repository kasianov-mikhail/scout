//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension [RetentionWeek] {
    init(cohorts: [RetentionCohort]) {
        self =
            cohorts
            .sorted { $0.id > $1.id }
            .prefix(4)
            .map { cohort in
                let kept = RetentionCohort.rate(cohort.retention, onDay: 7).map {
                    Int(($0 * Double(cohort.size)).rounded())
                }

                return RetentionWeek(start: cohort.id, installs: cohort.size, kept: kept)
            }
    }
}
