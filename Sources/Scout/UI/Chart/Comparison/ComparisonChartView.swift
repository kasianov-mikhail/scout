//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

/// Horizontal portion of each bucket slot occupied by a bar, derived from
/// `chartBarRatio` and shared by the marks and the `ReferenceOverlay` so the
/// reference marks match the bars exactly.
///
let barSlot: ClosedRange<Double> = (0.5 - chartBarRatio / 2)...(0.5 + chartBarRatio / 2)

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
        let pairs = self.pairs

        Chart(pairs) { pair in
            marks(for: pair)
        }
        .chartXScale(domain: xDomain(of: pairs))
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

    var pairs: [ComparisonPair<T>] {
        let counts = Dictionary(reference.map { ($0.date, $0.count) }, uniquingKeysWith: +)
        return segment.map { point in
            ComparisonPair(
                date: point.date,
                bin: binRange(of: point.date, unit: timing.unit),
                count: point.count,
                reference: counts[point.date]
            )
        }
    }

    /// Full bucket bands, so the edge bars are inset from the plot edges the
    /// same way binned `BarMark` charts are.
    ///
    func xDomain(of pairs: [ComparisonPair<T>]) -> ClosedRange<Date> {
        guard let first = pairs.map(\.bin.lowerBound).min(), let last = pairs.map(\.bin.upperBound).max() else {
            return Date().startOfDay...Date().startOfDay.addingDay()
        }
        return first...last
    }

    /// The bar for the current value, plus an invisible mark at the previous
    /// level so the y scale grows to a rounded maximum that fits reference
    /// contours rising above the bars.
    ///
    @ChartContentBuilder func marks(for pair: ComparisonPair<T>) -> some ChartContent {
        let length = pair.bin.upperBound.timeIntervalSince(pair.bin.lowerBound)
        let start: PlottableValue<Date> = .value("Start", pair.bin.lowerBound.addingTimeInterval(length * barSlot.lowerBound))
        let end: PlottableValue<Date> = .value("End", pair.bin.lowerBound.addingTimeInterval(length * barSlot.upperBound))
        let zero: PlottableValue<T> = .value("Zero", .zero)
        let count: PlottableValue<T> = .value("Count", pair.count)

        RectangleMark(xStart: start, xEnd: end, yStart: zero, yEnd: count)
            .foregroundStyle(color)
            .cornerRadius(3)

        if let reference = pair.reference {
            let center: PlottableValue<Date> = .value("Center", pair.bin.lowerBound.addingTimeInterval(length / 2))
            let level: PlottableValue<T> = .value("Reference", reference)

            PointMark(x: center, y: level)
                .opacity(0)
        }
    }
}

/// One bucket of the comparison: the current value and the previous-period
/// value it is compared against, both on the current bucket's date.
///
/// `reference` is nil when the previous window has no counterpart bucket —
/// calendar months differ in length, so the oldest buckets of a longer
/// current window have nothing to compare against.
///
struct ComparisonPair<T: ChartNumeric>: Identifiable {
    let date: Date
    let bin: Range<Date>
    let count: T
    let reference: T?

    var id: Date { date }
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
