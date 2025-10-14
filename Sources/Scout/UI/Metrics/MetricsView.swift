// wrap both previews into a VStack to avoid truncation
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

struct MetricsView<T: ChartNumeric>: View {
    @State private var period: Period
    let points: [ChartPoint<T>]

    init(period: Period, points: [ChartPoint<T>]) {
        self._period = State(wrappedValue: period)
        self.points = points
    }

    var body: some View {
        Picker("Period", selection: $period) {
            ForEach(Period.all) { period in
                Text(period.shortTitle.uppercased())
            }
        }
        .padding(.horizontal)
        .pickerStyle(.segmented)

        List {
            let extent = ChartExtent(period: period)

            ChartView(points: points, extent: extent)
                .foregroundStyle(.blue)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollDisabled(true)
    }
}

#Preview("MetricsView") {
    NavigationStack {
        MetricsView(period: .month, points: .sample).navigationTitle("MetricsView")
    }
}
