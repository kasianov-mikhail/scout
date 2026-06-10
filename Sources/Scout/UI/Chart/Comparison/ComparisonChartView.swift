//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

/// A bar chart of the current period with the previous period's per-bucket
/// levels drawn on top of it.
///
/// - where the value grew, a white dashed line marks the previous level and
///   the slice of the bar above it is lightened;
/// - where the value dropped, a dashed contour rises above the bar to the
///   previous level and the missing slice is tinted.
///
/// `reference` is expected to sit on the same bucket dates as `segment`
/// (see `ChartExtent.referenceSegment(from:alignedTo:)`); buckets missing
/// from it have no comparison data and draw no reference marks.
///
/// The y scale covers both periods, rounded up to a nice axis value the same
/// way plain bar charts round their maximum — so reference contours always
/// fit and the axis keeps regular tick values.
///
struct ComparisonChartView<T: ChartNumeric>: View {
    let segment: [ChartPoint<T>]
    let reference: [ChartPoint<T>]
    let timing: ChartTiming
    let color: Color

    var body: some View {
        let pairs = segment.paired(with: reference, unit: timing.unit)

        Chart(pairs) { pair in
            marks(for: pair)
        }
        .chartXScale(domain: pairs.xDomain())
        .chartXAxis {
            AxisMarks(format: timing.unit.chartFormat, values: timing.tickDates(for: segment))
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                ReferenceOverlay(
                    pairs: pairs,
                    proxy: proxy,
                    plotFrame: geo[proxy.plotAreaFrame],
                    color: color
                )
            }
        }
        .chartBackground { _ in
            if segment.total == .zero && reference.total == .zero {
                ChartPlaceholder()
            }
        }
        .aspectRatio(4 / 3, contentMode: .fit)
        .padding()
        .padding(.bottom)
        .listRowInsets(EdgeInsets())
    }

    /// The bar for the current value, plus an invisible mark at the previous
    /// level so the y scale grows to a rounded maximum that fits reference
    /// contours rising above the bars.
    ///
    @ChartContentBuilder func marks(for pair: ComparisonPair<T>) -> some ChartContent {
        RectangleMark(
            xStart: .value("Start", pair.barStart),
            xEnd: .value("End", pair.barEnd),
            yStart: .value("Zero", T.zero),
            yEnd: .value("Count", pair.count)
        )
        .foregroundStyle(color)
        .cornerRadius(3)

        if let reference = pair.reference {
            PointMark(x: .value("Center", pair.binCenter), y: .value("Reference", reference))
                .opacity(0)
        }
    }
}

// MARK: - Previews

#Preview("ComparisonChartView – Week") {
    let extent = ChartExtent(period: Period.week)
    let today = Date().startOfDay
    let counts = [14, 25, 17, 22, 9, 18, 12, 12, 16, 10, 19, 11, 15, 8]
    let points = counts.enumerated().map { i, count in
        ChartPoint(date: today.addingDay(-i - 1), count: count)
    }
    let segment = extent.segment(from: points)

    return VStack(alignment: .leading, spacing: 24) {
        Text(verbatim: "With Data").font(.headline)
        ComparisonChartView(
            segment: segment,
            reference: extent.referenceSegment(from: points, alignedTo: segment),
            timing: extent,
            color: .blue
        )

        Text(verbatim: "Empty State").font(.headline)
        ComparisonChartView(segment: .empty, reference: .empty, timing: extent, color: .blue)
    }
    .padding()
}
