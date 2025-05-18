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
