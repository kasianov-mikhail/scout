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
        let unit = timing.unit

        Chart(segment, id: \.date) { point in
            BarMark(
                x: .value("X", point.date, unit: unit),
                y: .value("Y", point.count)
            )
        }
        .chartXAxis {
            if let values = timing.tickValues {
                AxisMarks(format: unit.chartFormat, values: values)
            } else {
                AxisMarks(format: unit.chartFormat)
            }
        }
        .chartBackground { _ in
            if segment.total == .zero {
                Placeholder(text: "No results")
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
        Text("With Data").font(.headline)
        ChartView(segment: .sample, timing: ChartExtent(period: Period.month))

        Text("Empty State").font(.headline)
        ChartView(segment: .empty, timing: ChartExtent(period: Period.month))
    }
    .padding()
}
