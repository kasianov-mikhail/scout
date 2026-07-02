//
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
    @State private var isComparing = false

    init(group: PointGroup<T>, formatter: KeyPath<T, String>, period: Period) {
        self.group = group
        self.formatter = formatter
        self._extent = State(wrappedValue: ChartExtent(period: period))
    }

    var body: some View {
        PeriodPicker(selection: $extent.period)

        RangeControl(extent: $extent)

        List {
            let segment = extent.segment(from: group.points)

            ComparableChart(
                segment: segment,
                points: group.points,
                extent: extent,
                color: .blue,
                isComparing: isComparing
            )
            .chartYAxis(content: { formattedMarks })
            .listRowSeparator(.hidden)

            ComparisonToggle(isOn: $isComparing)
                .disabled(!extent.canCompare(points: group.points, segment: segment))
        }
        .listStyle(.plain)
        .navigationTitle(group.name)
        .scrollDisabled(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ChartExportButton(title: group.name, rangeLabel: extent.domain.label(using: rangeDateFormatter)) {
                    ChartView(segment: extent.segment(from: group.points), timing: extent)
                        .chartYAxis(content: { formattedMarks })
                        .foregroundStyle(.blue)
                }
            }
        }
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
