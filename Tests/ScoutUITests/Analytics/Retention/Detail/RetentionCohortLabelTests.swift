//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI
@testable import Support

struct RetentionCohortLabelTests {
    @Test("Reads its dates in UTC on any host")
    func testConfiguration() {
        #expect(DateFormatter.monthDay.timeZone == Calendar.utc.timeZone)
        #expect(DateFormatter.monthDay.calendar == .utc)
    }

    @Test("Labels read the cohort day in UTC from either end of it")
    func testUTC() {
        let midnight = Date(timeIntervalSince1970: 1_704_067_200).startOfWeek
        let lastSecond = midnight.addingDay().addingTimeInterval(-1)

        #expect(RetentionCohort(id: midnight, size: 10, retention: [], segments: []).label == "Dec 31")
        #expect(RetentionCohort(id: lastSecond, size: 10, retention: [], segments: []).label == "Dec 31")
    }

    @Test("A week inside one month names the month once")
    func sameMonthRange() {
        let cohort = RetentionCohort(id: Date(year: 2026, month: 10, day: 13), size: 10, retention: [], segments: [])

        #expect(cohort.weekRange == "Oct 13–19")
    }

    @Test("A week across two months names both")
    func crossMonthRange() {
        let cohort = RetentionCohort(id: Date(year: 2026, month: 9, day: 29), size: 10, retention: [], segments: [])

        #expect(cohort.weekRange == "Sep 29–Oct 5")
    }
}
