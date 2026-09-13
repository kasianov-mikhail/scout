//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct RetentionCohortRateTests {
    @Test("Reads the rate at a milestone")
    func milestone() {
        #expect(RetentionCohort.rate([1, 0.5, 0.4, 0.3, 0.2, 0.1], onDay: 7) == 0.3)
    }

    @Test("A day that is not a milestone has no rate")
    func nonMilestone() {
        #expect(RetentionCohort.rate([1, 0.5, 0.4, 0.3, 0.2, 0.1], onDay: 2) == nil)
    }

    @Test("A milestone the backend did not send reads as nil instead of trapping")
    func shortRetention() {
        #expect(RetentionCohort.rate([1, 0.5, 0.4, 0.3], onDay: 7) == 0.3)
        #expect(RetentionCohort.rate([1, 0.5, 0.4, 0.3], onDay: 30) == nil)
        #expect(RetentionCohort.rate([], onDay: 0) == nil)
    }
}
