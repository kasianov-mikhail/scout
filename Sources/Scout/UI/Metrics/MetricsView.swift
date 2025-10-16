// wrap both previews into a VStack to avoid truncation
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

struct MetricsView<T: ChartNumeric>: View {
    let points: [ChartPoint<T>]
    @State private var extent: ChartExtent<Period>

    init(points: [ChartPoint<T>], period: Period) {
        self.points = points
        self._extent = State(wrappedValue: ChartExtent(period: period))
    }

    var body: some View {
        Picker("Period", selection: $extent.period) {
            ForEach(Period.all) { period in
                Text(period.shortTitle.uppercased())
            }
        }
        .padding(.horizontal)
        .pickerStyle(.segmented)

        RangeControl(extent: $extent)

        List {
            ChartView(points: extent.segment(from: points), timing: extent)
                .foregroundStyle(.blue)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollDisabled(true)
    }
}

#Preview("MetricsView") {
    NavigationStack {
        MetricsView(points: .sample, period: .month).navigationTitle("MetricsView")
    }
}
