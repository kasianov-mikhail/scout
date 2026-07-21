//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI
@testable import Support

@Suite("Ranked series")
struct RankedSeriesTests {
    private let period = Period.today

    private func group(_ name: String, _ values: [Double]) -> PointGroup<Double> {
        let start = period.initialRange.lowerBound
        let points = values.enumerated().map { hour, value in
            ChartPoint(date: start.addingTimeInterval(TimeInterval(hour) * .hour), count: value)
        }
        return PointGroup(name: name, points: points)
    }

    @Test("Totals rank by sum and drop the empty series")
    func totalRanking() {
        let ranked = [group("idle", [0, 0]), group("busy", [1, 2]), group("quiet", [1])]
            .ranked(on: period, by: .total)

        #expect(ranked.map(\.name) == ["busy", "quiet"])
    }

    @Test("Latest keeps a gauge that reads zero")
    func latestKeepsZero() {
        let ranked = [group("idle", [5, 0])].ranked(on: period, by: .latest)

        #expect(ranked.map(\.name) == ["idle"])
    }

    @Test("Latest keeps a gauge that went negative")
    func latestKeepsNegative() {
        let ranked = [group("drained", [2, -3])].ranked(on: period, by: .latest)

        #expect(ranked.map(\.name) == ["drained"])
    }

    @Test("Latest ranks on the newest value, not the sum")
    func latestRanksOnNewestValue() {
        let ranked = [group("spiky", [100, 1]), group("steady", [4, 5])]
            .ranked(on: period, by: .latest)

        #expect(ranked.map(\.name) == ["steady", "spiky"])
    }

    @Test("Latest still drops a series with no points in the period")
    func latestDropsEmptySeries() {
        let ranked = [group("absent", []), group("present", [0])]
            .ranked(on: period, by: .latest)

        #expect(ranked.map(\.name) == ["present"])
    }
}
