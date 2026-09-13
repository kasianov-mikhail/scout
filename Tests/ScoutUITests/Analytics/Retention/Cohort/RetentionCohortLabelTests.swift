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
    @Test("Reads its dates in UTC on any host")
    func testConfiguration() {
        #expect(DateFormatter.cohortDay.timeZone == Calendar.utc.timeZone)
        #expect(DateFormatter.cohortDay.calendar == .utc)
    }

    @Test("Labels read the cohort day in UTC from either end of it")
    func testUTC() {
        // 2024-01-01T00:00:00Z is a Monday, so its UTC week starts the Sunday before.
        let midnight = Date(timeIntervalSince1970: 1_704_067_200).startOfWeek
        let lastSecond = midnight.addingDay().addingTimeInterval(-1)

        #expect(RetentionCohort(id: midnight, size: 10, retention: [], segments: []).label == "Dec 31")
        #expect(RetentionCohort(id: lastSecond, size: 10, retention: [], segments: []).label == "Dec 31")
    }
}
