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
    @State private var isComparing = false

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

        List {
            chart(segment: extent.segment(from: group.points))
                .chartYAxis(content: { formattedMarks })
                .listRowSeparator(.hidden)

            ComparisonToggle(isOn: $isComparing)
        }
        .listStyle(.plain)
        .navigationTitle(group.name)
        .scrollDisabled(true)
    }

    @ViewBuilder func chart(segment: [ChartPoint<T>]) -> some View {
        if isComparing {
            ComparisonChartView(
                segment: segment,
                reference: extent.referenceSegment(from: group.points),
                timing: extent,
                color: .blue
            )
        } else {
            ChartView(segment: segment, timing: extent)
                .foregroundStyle(.blue)
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
