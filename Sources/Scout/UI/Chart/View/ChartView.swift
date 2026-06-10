//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

/// Fraction of its slot a bar occupies.
///
/// Pinned explicitly on both the plain bar marks and the comparison chart's
/// geometry, so the two modes render identical bars regardless of the
/// framework's default width.
///
let chartBarRatio: Double = 0.7

struct ChartView<T: ChartNumeric>: View {
    let segment: [ChartPoint<T>]
    let timing: ChartTiming

    var body: some View {
        let unit = timing.unit

        Chart(segment, id: \.date) { point in
            BarMark(
                x: .value("X", point.date, unit: unit),
                y: .value("Y", point.count),
                width: .ratio(chartBarRatio)
            )
        }
        .chartXAxis {
            AxisMarks(format: unit.chartFormat, values: timing.tickDates(for: segment))
        }
        .chartBackground { _ in
            if segment.total == .zero {
                ChartPlaceholder()
            }
        }
        .aspectRatio(4 / 3, contentMode: .fit)
        .padding()
        .padding(.bottom)
        .listRowInsets(EdgeInsets())
    }
}

#Preview("ChartView – Month") {
    VStack(alignment: .leading, spacing: 24) {
        Text(verbatim: "With Data").font(.headline)
        ChartView(segment: .sample, timing: ChartExtent(period: Period.month))

        Text(verbatim: "Empty State").font(.headline)
        ChartView(segment: .empty, timing: ChartExtent(period: Period.month))
    }
    .padding()
}
