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

struct ActivityPeriodTests {
    @Test(
        "Each period opens the activity level it can show",
        arguments: zip(Period.allCases, [ActivityPeriod.daily, .daily, .weekly, .monthly, .monthly])
    )
    func activityPeriod(period: Period, metric: ActivityPeriod) {
        #expect(period.activityPeriod == metric)
    }

    @Test("The metric picker names the levels the way the charts do")
    func titles() {
        #expect(ActivityPeriod.allCases.map(\.rawValue) == ["DAU", "WAU", "MAU"])
    }
}
