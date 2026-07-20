//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import Scout
import SwiftUI

struct ChartView<T: ChartNumeric>: View {
    let segment: [ChartPoint<T>]
    let timing: ChartTiming

    var body: some View {
        let isEmpty = segment.total == .zero

        Chart(segment, id: \.date) { point in
            BarMark(
                x: .value("X", point.date, unit: timing.unit),
                y: .value("Y", point.count),
                width: .ratio(ChartGeometry.barRatio)
            )
        }
        .placeholderAxis(active: isEmpty)
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
        .environment(\.calendar, .utc)
        .environment(\.timeZone, Calendar.utc.timeZone)
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
