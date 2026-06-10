//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

/// Horizontal portion of each bucket slot occupied by a bar.
///
/// Shared by the marks and the overlay so the reference marks match the bars
/// exactly. The centered 70% of the slot matches the default `BarMark` width,
/// keeping bars the same size as in the plain `ChartView`.
///
private let barSlot: ClosedRange<Double> = 0.15...0.85

private let referenceDash = StrokeStyle(lineWidth: 1.5, dash: [4, 4])

/// The time slot a bucket occupies on the x axis.
///
/// `BarMark` bins dates with the local calendar, so the comparison chart
/// derives its bar slots, domain, and ticks from the same bins to keep the
/// two modes pixel-aligned.
///
private func binRange(of date: Date, unit: Calendar.Component) -> Range<Date> {
    let interval = Calendar.autoupdatingCurrent.dateInterval(of: unit, for: date)!
    return interval.start..<interval.end
}

/// A bar chart of the current period with the previous period's per-bucket
/// levels drawn on top of it.
///
/// - where the value grew, a white dashed line marks the previous level and
///   the slice of the bar above it is lightened;
/// - where the value dropped, a dashed contour rises above the bar to the
///   previous level and the missing slice is tinted.
///
/// `reference` is expected to sit on the same bucket dates as `segment`
/// (see `ChartExtent.referenceSegment(from:)`); buckets missing from it are
/// treated as zero.
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
        let unit = timing.unit

        Chart(pairs) { pair in
            bar(for: pair)
            scaleAnchor(for: pair)
        }
        .chartXScale(domain: xDomain)
        .chartXAxis {
            AxisMarks(format: unit.chartFormat, values: timing.tickValues ?? tickDates)
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                ReferenceOverlay(
                    pairs: pairs,
                    proxy: proxy,
                    plotFrame: geo[proxy.plotAreaFrame],
                    unit: unit,
                    color: color
                )
            }
        }
        .chartBackground { _ in
            if segment.total == .zero && reference.total == .zero {
                Text(verbatim: "No results")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.gray.opacity(0.7))
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
            ComparisonPair(date: point.date, count: point.count, reference: counts[point.date] ?? .zero)
        }
    }

    /// Full bucket bands, so the edge bars are inset from the plot edges the
    /// same way binned `BarMark` charts are.
    ///
    var xDomain: ClosedRange<Date> {
        let dates = segment.map(\.date)
        guard let first = dates.min(), let last = dates.max() else {
            return Date().startOfDay...Date().startOfDay.addingDay()
        }
        return binRange(of: first, unit: timing.unit).lowerBound...binRange(of: last, unit: timing.unit).upperBound
    }

    /// Bucket bin starts thinned to at most four ticks — the same dates the
    /// default axis of a binned `BarMark` chart picks.
    ///
    var tickDates: [Date] {
        let starts = segment.map { binRange(of: $0.date, unit: timing.unit).lowerBound }.sorted()
        let step = max(1, (starts.count + 3) / 4)
        return stride(from: 0, to: starts.count, by: step).map { starts[$0] }
    }

    func bar(for pair: ComparisonPair<T>) -> some ChartContent {
        let bin = binRange(of: pair.date, unit: timing.unit)
        let length = bin.upperBound.timeIntervalSince(bin.lowerBound)
        let start: PlottableValue<Date> = .value("Start", bin.lowerBound.addingTimeInterval(length * barSlot.lowerBound))
        let end: PlottableValue<Date> = .value("End", bin.lowerBound.addingTimeInterval(length * barSlot.upperBound))
        let zero: PlottableValue<T> = .value("Zero", .zero)
        let count: PlottableValue<T> = .value("Count", pair.count)

        return RectangleMark(xStart: start, xEnd: end, yStart: zero, yEnd: count)
            .foregroundStyle(color)
            .cornerRadius(3)
    }

    /// An invisible mark at the previous level, so the y scale grows to a
    /// rounded maximum that fits reference contours rising above the bars.
    ///
    func scaleAnchor(for pair: ComparisonPair<T>) -> some ChartContent {
        let bin = binRange(of: pair.date, unit: timing.unit)
        let center: PlottableValue<Date> = .value("Center", bin.lowerBound.addingTimeInterval(bin.upperBound.timeIntervalSince(bin.lowerBound) / 2))
        let reference: PlottableValue<T> = .value("Reference", pair.reference)

        return PointMark(x: center, y: reference)
            .opacity(0)
    }
}

/// One bucket of the comparison: the current value and the previous-period
/// value it is compared against, both on the current bucket's date.
///
struct ComparisonPair<T: ChartNumeric>: Identifiable {
    let date: Date
    let count: T
    let reference: T

    var id: Date { date }
}

// MARK: - Overlay

/// Draws the previous-period levels over the plot area using chart-proxy
/// coordinates, since bar marks cannot render dashed strokes.
///
private struct ReferenceOverlay<T: ChartNumeric>: View {
    let pairs: [ComparisonPair<T>]
    let proxy: ChartProxy
    let plotFrame: CGRect
    let unit: Calendar.Component
    let color: Color

    var body: some View {
        ZStack {
            slices { $0.reference <= $0.count }
                .fill(.white.opacity(0.25))
            slices { $0.reference > $0.count }
                .fill(color.opacity(0.12))
            referenceLines()
                .stroke(style: referenceDash)
                .foregroundStyle(.white)
            referenceContours()
                .stroke(style: referenceDash)
                .foregroundStyle(color)
        }
    }

    /// Rectangles between the two periods' levels for the matching buckets.
    func slices(where matches: (ComparisonPair<T>) -> Bool) -> Path {
        Path { path in
            for pair in pairs where matches(pair) && !isEmpty(pair) {
                guard let frame = frame(for: pair) else { continue }
                let top = min(frame.count, frame.reference)
                let bottom = max(frame.count, frame.reference)
                path.addRect(
                    CGRect(
                        x: frame.x.lowerBound,
                        y: top,
                        width: frame.x.upperBound - frame.x.lowerBound,
                        height: bottom - top
                    )
                )
            }
        }
    }

    /// White dashed lines across the bars where the value grew.
    func referenceLines() -> Path {
        Path { path in
            for pair in pairs where pair.reference <= pair.count && !isEmpty(pair) {
                guard let frame = frame(for: pair) else { continue }
                path.move(to: CGPoint(x: frame.x.lowerBound, y: frame.reference))
                path.addLine(to: CGPoint(x: frame.x.upperBound, y: frame.reference))
            }
        }
    }

    /// Dashed contours rising above the bars where the value dropped.
    ///
    /// A contour clipped by the plot's top edge is left without its cap to
    /// show that the previous level lies beyond the visible scale.
    ///
    func referenceContours() -> Path {
        Path { path in
            for pair in pairs where pair.reference > pair.count {
                guard let frame = frame(for: pair) else { continue }
                path.move(to: CGPoint(x: frame.x.lowerBound, y: frame.count))
                path.addLine(to: CGPoint(x: frame.x.lowerBound, y: frame.reference))
                if frame.isClamped {
                    path.move(to: CGPoint(x: frame.x.upperBound, y: frame.reference))
                } else {
                    path.addLine(to: CGPoint(x: frame.x.upperBound, y: frame.reference))
                }
                path.addLine(to: CGPoint(x: frame.x.upperBound, y: frame.count))
            }
        }
    }

    func isEmpty(_ pair: ComparisonPair<T>) -> Bool {
        pair.count == .zero && pair.reference == .zero
    }

    /// Bar-aligned geometry for one bucket, in overlay coordinates.
    func frame(for pair: ComparisonPair<T>) -> (x: ClosedRange<CGFloat>, count: CGFloat, reference: CGFloat, isClamped: Bool)? {
        let bin = binRange(of: pair.date, unit: unit)
        guard let slotStart = proxy.position(forX: bin.lowerBound), let slotEnd = proxy.position(forX: bin.upperBound) else {
            return nil
        }
        guard let countY = proxy.position(forY: pair.count), let referenceY = proxy.position(forY: pair.reference) else {
            return nil
        }
        let width = slotEnd - slotStart
        let lower = plotFrame.minX + slotStart + width * barSlot.lowerBound
        let upper = plotFrame.minX + slotStart + width * barSlot.upperBound
        let reference = plotFrame.minY + referenceY
        return (lower...upper, plotFrame.minY + countY, max(reference, plotFrame.minY), isClamped: reference < plotFrame.minY)
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

    return VStack(alignment: .leading, spacing: 24) {
        Text(verbatim: "With Data").font(.headline)
        ComparisonChartView(
            segment: extent.segment(from: points),
            reference: extent.referenceSegment(from: points),
            timing: extent,
            color: .blue
        )

        Text(verbatim: "Empty State").font(.headline)
        ComparisonChartView(segment: .empty, reference: .empty, timing: extent, color: .blue)
    }
    .padding()
}
