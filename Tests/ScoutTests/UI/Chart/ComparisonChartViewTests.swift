//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI
import Testing
import UIKit

@testable import Scout

/// Render smoke tests: drawing the chart through `ImageRenderer` exercises
/// the whole pipeline — pairing, the marks, and the reference overlay
/// projecting levels through a live `ChartProxy`.
///
struct ComparisonChartViewTests {
    @Test("Renders bars with the reference overlay") @MainActor func testRender() {
        let extent = ChartExtent(period: Period.week)
        let points = makePoints(in: extent.domain, count: 2) + makePoints(in: extent.previousDomain, count: 5)
        let segment = extent.segment(from: points)

        let renderer = ImageRenderer(
            content: ComparisonChartView(
                segment: segment,
                reference: extent.referenceSegment(from: points, alignedTo: segment),
                timing: extent,
                color: .blue
            )
            .frame(width: 400, height: 300)
        )

        #expect(renderer.uiImage?.size == CGSize(width: 400, height: 300))
    }

    @Test("Renders the placeholder when both periods are empty") @MainActor func testEmptyRender() {
        let extent = ChartExtent(period: Period.week)

        let renderer = ImageRenderer(
            content: ComparisonChartView(segment: .empty, reference: .empty, timing: extent, color: .blue)
                .frame(width: 400, height: 300)
        )

        #expect(renderer.uiImage?.size == CGSize(width: 400, height: 300))
    }

    func makePoints(in range: Range<Date>, count: Int) -> [ChartPoint<Int>] {
        var points: [ChartPoint<Int>] = []
        var date = range.lowerBound

        while date < range.upperBound {
            points.append(ChartPoint(date: date, count: count))
            date.addDay()
        }

        return points
    }
}
