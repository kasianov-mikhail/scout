// wrap both previews into a VStack to avoid truncation
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

struct MetricsView<T: ChartNumeric>: View {
    let group: PointGroup<T>
    @State private var extent: ChartExtent<Period>

    init(group: PointGroup<T>, period: Period) {
        self.group = group
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
            let segment = extent.segment(from: group.points)

            ChartView(segment: segment, timing: extent)
                .foregroundStyle(.blue)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationTitle(group.name)
        .scrollDisabled(true)
    }
}

#Preview("MetricsView") {
    NavigationStack {
        MetricsView(group: .init(name: "Group", points: .sample), period: .month)
    }
}
