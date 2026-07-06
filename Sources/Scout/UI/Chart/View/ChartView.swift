//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

struct ChartView<T: ChartNumeric>: View {
    let segment: [ChartPoint<T>]
    let timing: ChartTiming

    var body: some View {
        let isEmpty = segment.total == .zero

        chart(isEmpty: isEmpty)
            .chartXAxis {
                AxisMarks(format: timing.unit.chartFormat, values: timing.tickDates(for: segment))
            }
            .chartBackground { _ in
                if isEmpty {
                    ChartPlaceholder()
                }
            }
            .aspectRatio(4 / 3, contentMode: .fit)
            .padding()
            .padding(.bottom)
            .listRowInsets(EdgeInsets())
    }

    @ViewBuilder
    private func chart(isEmpty: Bool) -> some View {
        if isEmpty {
            bars.placeholderAxis
        } else {
            bars
        }
    }

    private var bars: some View {
        Chart(segment, id: \.date) { point in
            BarMark(
                x: .value("X", point.date, unit: timing.unit),
                y: .value("Y", point.count),
                width: .ratio(ChartGeometry.barRatio)
            )
        }
    }
}

extension View {
    fileprivate var placeholderAxis: some View {
        chartYScale(domain: 0...1).chartYAxis {
            AxisMarks(values: [0, 1]) { _ in
                AxisGridLine()
            }
        }
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
