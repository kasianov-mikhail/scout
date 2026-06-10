//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

/// Renders a chart for the visible time window, optionally comparing it with
/// the previous window using the selected ``ChartComparison`` display option.
///
/// Without a comparison the view falls back to a plain ``ChartView``.
///
struct ComparisonChartView<S: ChartTimeScale, T: ChartNumeric>: View {
    let points: [ChartPoint<T>]
    let extent: ChartExtent<S>
    let comparison: ChartComparison?

    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        switch comparison {
        case nil:
            ChartView(segment: extent.segment(from: points), timing: extent)
        case .overlay:
            overlay
        case .split:
            split
        }
    }

    var overlay: some View {
        VStack(spacing: 0) {
            legend

            ChartView(
                segment: extent.segment(from: points),
                comparison: extent.overlaySegment(from: points),
                timing: extent
            )
        }
        .listRowInsets(EdgeInsets())
    }

    var split: some View {
        VStack(spacing: 0) {
            label(for: extent.domain)
            ChartView(segment: extent.segment(from: points), aspectRatio: 2, timing: extent)

            label(for: extent.previousDomain)
            ChartView(
                segment: extent.previousSegment(from: points),
                aspectRatio: 2,
                timing: extent.previousExtent
            )
            .foregroundStyle(.gray)
        }
        .listRowInsets(EdgeInsets())
    }

    var legend: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 10, height: 10)
                Text(extent.domain.label(using: formatter))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 6) {
                Capsule()
                    .fill(.gray)
                    .frame(width: 10, height: 3)
                Text(extent.previousDomain.label(using: formatter))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .font(.footnote)
        .monospaced()
        .padding(.horizontal)
        .padding(.top)
    }

    func label(for range: Range<Date>) -> some View {
        Text(range.label(using: formatter))
            .font(.footnote)
            .monospaced()
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top)
    }
}

// MARK: - Previews

#Preview("ComparisonChartView") {
    let sample: [ChartPoint<Int>] = .sample
    let shifted = sample.map { point in
        ChartPoint(date: point.date.addingWeek(-1), count: point.count)
    }
    let points = sample + shifted

    return List {
        ComparisonChartView(
            points: points,
            extent: ChartExtent(period: Period.week),
            comparison: .overlay
        )
        .foregroundStyle(.blue)

        ComparisonChartView(
            points: points,
            extent: ChartExtent(period: Period.week),
            comparison: .split
        )
        .foregroundStyle(.blue)
    }
    .listStyle(.plain)
}
