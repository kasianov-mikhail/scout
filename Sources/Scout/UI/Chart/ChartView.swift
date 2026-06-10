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
    var comparison: [ChartPoint<T>]? = nil

    var body: some View {
        let unit = timing.unit

        Chart {
            ForEach(segment, id: \.date) { point in
                BarMark(
                    x: .value("X", point.date, unit: unit),
                    y: .value("Y", point.count)
                )
            }

            if let comparison {
                ForEach(comparison, id: \.date) { point in
                    LineMark(
                        x: .value("X", point.date, unit: unit),
                        y: .value("Y", point.count)
                    )
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .symbol(.circle)
                }
            }
        }
        .chartXAxis {
            if let values = timing.tickValues {
                AxisMarks(format: unit.chartFormat, values: values)
            } else {
                AxisMarks(format: unit.chartFormat)
            }
        }
        .chartBackground { _ in
            if segment.total == .zero, (comparison ?? []).total == .zero {
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

#Preview("ChartView – Comparison") {
    let extent = ChartExtent(
        period: Period.week,
        domain: Period.week.initialRange,
        isComparing: true
    )
    let end = Date()
    let points = (0..<336).compactMap { i in
        Calendar.utc.date(byAdding: .hour, value: -i, to: end).map {
            ChartPoint(date: $0, count: Int.random(in: 0...20))
        }
    }

    ChartView(
        segment: extent.segment(from: points),
        timing: extent,
        comparison: extent.comparison(from: points)
    )
    .padding()
}
