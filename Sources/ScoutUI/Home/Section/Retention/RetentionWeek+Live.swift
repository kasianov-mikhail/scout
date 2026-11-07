//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension RetentionWeek {
    init(cohort: RetentionCohort, day: RetentionDay) {
        self.init(start: cohort.id, installs: cohort.size, kept: cohort.kept(onDay: day), day: day)
    }
}

extension [RetentionWeek] {
    init(cohorts: [RetentionCohort]) {
        self = cohorts.sorted(by: >).prefix(4).map { RetentionWeek(cohort: $0, day: .day7) }
    }
}
