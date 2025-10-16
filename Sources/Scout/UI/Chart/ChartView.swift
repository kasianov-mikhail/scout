//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

struct ChartView<T: ChartTimeScale, V: ChartNumeric>: View {
    let points: [ChartPoint<V>]
    let extent: ChartExtent<T>

    var body: some View {
        Chart(points, id: \.date) { point in
            BarMark(
                x: .value("X", point.date, unit: extent.period.pointComponent),
                y: .value("Y", point.count)
            )
        }
        .chartXAxis {
            if let axisValues = extent.axisValues {
                AxisMarks(values: axisValues)
            } else {
                AxisMarks()
            }
        }
        .chartBackground { proxy in
            if points.total == .zero {
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
        ChartView(points: .sample, extent: .init(period: Period.month))

        Text("Empty State").font(.headline)
        ChartView(points: .empty, extent: .init(period: Period.month))
    }
    .padding()
}
