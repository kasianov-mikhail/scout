//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

struct ChartView<T: ChartCompatible>: View {
    let points: [ChartPoint]
    let model: StatModel<T>

    var body: some View {
        Chart(points, id: \.date) { point in
            BarMark(
                x: .value("X", point.date, unit: model.period.pointComponent),
                y: .value("Y", point.count)
            )
        }
        .chartXAxis {
            if let axisValues = model.axisValues {
                AxisMarks(values: axisValues)
            } else {
                AxisMarks()
            }
        }
        .chartBackground { proxy in
            if points.count == 0 {
                Placeholder(text: "No results")
            }
        }
        .aspectRatio(4 / 3, contentMode: .fit)
        .padding()
        .padding(.bottom)
        .listRowInsets(EdgeInsets())
    }
}

// MARK: - ChartView Extensions

extension StatModel {

    /// Returns the axis values for the chart.
    ///
    /// For a month period, the values are the last 4 weeks. This fixes the issue with the axis
    /// values not being displayed correctly for the month period. For the other periods,
    /// the chart uses default axis values
    ///
    fileprivate var axisValues: [Date]? {
        if period.rangeComponent == .month {
            return [-28, -21, -14, -7].map(range.upperBound.addingDay)
        } else {
            return nil
        }
    }
}
