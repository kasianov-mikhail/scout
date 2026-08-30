//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

struct RetentionCohortLabelTests {
    /// Cohort ids are UTC week starts, so the label has to read them in UTC — in any
    /// other zone "Week of" names the wrong week boundary.
    @Test("Reads its dates in UTC, like the cohort ids it labels") func testTimeZone() {
        #expect(cohortDateFormatter.timeZone == Calendar.utc.timeZone)
        #expect(cohortDateFormatter.calendar == .utc)
    }

    @Test("Labels a cohort with its UTC week start") func testLabel() {
        // 2024-01-01T00:00:00Z is a Monday, so its UTC week starts the Sunday before.
        let weekStart = Date(timeIntervalSince1970: 1_704_067_200).startOfWeek
        let cohort = RetentionCohort(id: weekStart, size: 10, retention: [])

        #expect(cohort.label == "Dec 31")
    }
}
