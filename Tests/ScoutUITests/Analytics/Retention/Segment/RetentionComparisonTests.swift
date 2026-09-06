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

struct RetentionComparisonTests {
    private let cohort = RetentionCohort(id: Date(), size: 100, retention: [1, 0.5, 0.4, 0.25, 0.2, 0.1])

    private func segment(size: Int = 20, day7: Double?) -> RetentionSegment {
        RetentionSegment(name: "iOS 16", size: size, retention: [1, 0.5, 0.4, day7, 0.1, 0.05])
    }

    @Test("A segment retaining worse than the other versions reads as below")
    func below() {
        let comparison = RetentionComparison(segment: segment(day7: 0.19), cohort: cohort)

        #expect(comparison?.text == "Day 7 retention runs 28% below the rest of the cohort")
    }

    @Test("A segment retaining better than the other versions reads as above")
    func above() {
        let comparison = RetentionComparison(segment: segment(day7: 0.3), cohort: cohort)

        #expect(comparison?.text == "Day 7 retention runs 26% above the rest of the cohort")
    }

    @Test("A difference inside the tolerance tracks the rest of the cohort")
    func tracks() {
        let comparison = RetentionComparison(segment: segment(day7: 0.252), cohort: cohort)

        #expect(comparison?.text == "Day 7 retention tracks the rest of the cohort")
    }

    @Test("The baseline excludes the segment, so a dominant segment is still compared to the others")
    func dominantSegment() throws {
        let comparison = try #require(RetentionComparison(segment: segment(size: 95, day7: 0.26), cohort: cohort))

        #expect(comparison.text == "Day 7 retention runs 333% above the rest of the cohort")
    }

    @Test("Nothing to compare without a matured milestone or without other installs")
    func nothingToCompare() {
        #expect(RetentionComparison(segment: segment(day7: nil), cohort: cohort) == nil)
        #expect(RetentionComparison(segment: segment(size: 100, day7: 0.25), cohort: cohort) == nil)
        #expect(RetentionComparison(segment: segment(size: 20, day7: 1.25), cohort: cohort) == nil)
    }
}
