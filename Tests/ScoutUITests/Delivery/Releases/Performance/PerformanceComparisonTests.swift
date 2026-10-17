//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import ScoutUI

@Suite("PerformanceComparison")
struct PerformanceComparisonTests {
    @Test("The change is relative to the previous version")
    func relativeChange() {
        let comparison = PerformanceComparison(
            current: PerformanceSummary(hangMilliseconds: 6_000, foregroundSeconds: 3_600),
            previous: PerformanceSummary(hangMilliseconds: 4_000, foregroundSeconds: 3_600)
        )

        #expect(comparison.change(\.hangRate) == 0.5)
    }

    @Test("Without a previous value there is no change")
    func noPrevious() {
        let current = PerformanceSummary(hangMilliseconds: 6_000, foregroundSeconds: 3_600)

        #expect(PerformanceComparison(current: current, previous: nil).change(\.hangRate) == nil)
        #expect(PerformanceComparison(current: current, previous: PerformanceSummary()).change(\.hangRate) == nil)
    }

    @Test("A zero previous value has no relative change")
    func zeroPrevious() {
        let comparison = PerformanceComparison(
            current: PerformanceSummary(hangMilliseconds: 6_000, foregroundSeconds: 3_600),
            previous: PerformanceSummary(hangMilliseconds: 0, foregroundSeconds: 3_600)
        )

        #expect(comparison.change(\.hangRate) == nil)
    }
}
