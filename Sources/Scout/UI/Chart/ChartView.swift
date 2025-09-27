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

extension StatModel {
    fileprivate var axisValues: [Date]? {
        if period.rangeComponent == .month {
            return [-28, -21, -14, -7].map(range.upperBound.addingDay)
        } else {
            return nil
        }
    }
}

#Preview("ChartView – Month") {
    let model = StatModel(period: Period.month)

    let cal = Calendar(identifier: .iso8601)
    let end = model.range.upperBound
    let points: [ChartPoint] = (1...30).compactMap { i in
        cal.date(byAdding: .day, value: -i, to: end).map {
            ChartPoint(date: $0, count: Int.random(in: 0...10))
        }
    }.sorted()

    return VStack(alignment: .leading, spacing: 24) {
        Text("With Data").font(.headline)
        ChartView(points: points, model: model)

        Text("Empty State").font(.headline)
        ChartView(points: [], model: model)
    }
    .padding()
}
