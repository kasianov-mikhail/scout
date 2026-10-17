//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI
import Testing

@testable import ScoutUI

@Suite("PerformanceComparison")
struct PerformanceComparisonTests {
    @Test("The change is relative to the previous version")
    func relativeChange() {
        let comparison = PerformanceComparison(
            current: PerformanceSummary(hangMilliseconds: 6_000, foregroundSeconds: 3_600),
            previous: .init(version: "1.0", summary: PerformanceSummary(hangMilliseconds: 4_000, foregroundSeconds: 3_600))
        )

        #expect(comparison.change(\.hangRate) == 0.5)
    }

    @Test("Without a previous value there is no change")
    func noPrevious() {
        let current = PerformanceSummary(hangMilliseconds: 6_000, foregroundSeconds: 3_600)

        #expect(PerformanceComparison(current: current, previous: nil).change(\.hangRate) == nil)
        #expect(PerformanceComparison(current: current, previous: .init(version: "1.0", summary: PerformanceSummary())).change(\.hangRate) == nil)
    }

    @Test("A zero previous value has no relative change")
    func zeroPrevious() {
        let comparison = PerformanceComparison(
            current: PerformanceSummary(hangMilliseconds: 6_000, foregroundSeconds: 3_600),
            previous: .init(version: "1.0", summary: PerformanceSummary(hangMilliseconds: 0, foregroundSeconds: 3_600))
        )

        #expect(comparison.change(\.hangRate) == nil)
    }

    @Test("A readout turns orange on a regression and green on an improvement")
    func readoutColors() {
        let comparison = PerformanceComparison(
            current: PerformanceSummary(hangMilliseconds: 6_000, foregroundSeconds: 3_600),
            previous: .init(version: "1.0", summary: PerformanceSummary(hangMilliseconds: 4_000, foregroundSeconds: 3_600))
        )
        let better = PerformanceComparison(
            current: PerformanceSummary(hangMilliseconds: 2_000, foregroundSeconds: 3_600),
            previous: .init(version: "1.0", summary: PerformanceSummary(hangMilliseconds: 4_000, foregroundSeconds: 3_600))
        )

        #expect(comparison.readouts.map(\.value) == [nil, "6.0 s/h", nil])
        #expect(comparison.readouts[1].color == .orange)
        #expect(better.readouts[1].color == .green)
        #expect(comparison.readouts[0].color == .primary)
    }

    @Test("Launch bars give each version's share per cell up to the slowest launch")
    func launchBars() {
        var current = PerformanceSummary()
        current.launchHistogram.add(count: 3, at: 2)
        current.launchHistogram.add(count: 1, at: 4)
        var previous = PerformanceSummary()
        previous.launchHistogram.add(count: 2, at: 1)
        let comparison = PerformanceComparison(current: current, previous: .init(version: "1.0", summary: previous))

        let bars = comparison.launchBars(version: "2.0")

        #expect(bars.map(\.start) == [0, 100, 200, 300, 400, 0, 100, 200, 300, 400])
        #expect(bars.filter { $0.version == "2.0" }.map(\.share) == [0, 0, 0.75, 0, 0.25])
        #expect(bars.filter { $0.version == "1.0" }.map(\.share) == [0, 1, 0, 0, 0])
        #expect(LaunchBar.axisLabel(category: "1500") == "1.5 s")
        #expect(LaunchBar.axisLabel(category: "1400") == nil)
    }
}
