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
    let formatter: KeyPath<T, String>

    @State var extent: ChartExtent<Period>
    @State var comparison: ChartComparison?

    init(group: PointGroup<T>, formatter: KeyPath<T, String>, period: Period) {
        self.group = group
        self.formatter = formatter
        self._extent = State(wrappedValue: ChartExtent(period: period))
    }

    var body: some View {
        Picker(selection: $extent.period) {
            ForEach(Period.allCases) { period in
                Text(period.shortTitle.uppercased())
            }
        } label: {
            Text(verbatim: "Period")
        }
        .padding(.horizontal)
        .pickerStyle(.segmented)

        RangeControl(extent: $extent)
        ComparisonPicker(comparison: $comparison)

        List {
            ComparisonChartView(points: group.points, extent: extent, comparison: comparison)
                .chartYAxis(content: { formattedMarks })
                .foregroundStyle(.blue)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationTitle(group.name)
        .scrollDisabled(comparison == nil)
    }

    private var formattedMarks: some AxisContent {
        AxisMarks { value in
            if let value = value.as(T.self) {
                AxisGridLine()
                AxisValueLabel(value[keyPath: formatter])
            }
        }
    }
}

#Preview("MetricsView") {
    NavigationStack {
        MetricsView(
            group: .init(name: "Group", points: .sample),
            formatter: \.plain,
            period: .yesterday
        )
    }
}
