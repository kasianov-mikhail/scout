//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Charts
import SwiftUI

struct MetricsView<T: ChartNumeric, Extra: View>: View {
    let group: PointGroup<T>
    let formatter: KeyPath<T, String>

    @State var extent: ChartExtent<Period>
    @State private var isComparing = false
    @ViewBuilder let extra: (ChartExtent<Period>) -> Extra

    init(group: PointGroup<T>, formatter: KeyPath<T, String>, period: Period, @ViewBuilder extra: @escaping (ChartExtent<Period>) -> Extra) {
        self.group = group
        self.formatter = formatter
        self.extra = extra
        self._extent = State(wrappedValue: ChartExtent(period: period))
    }

    var body: some View {
        SegmentStrip(selection: $extent.period, title: \.shortTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

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

            extra(extent)
        }
        .listStyle(.plain)
        .monospacedNavigationTitle(en: group.name)
        .scrollDisabled(Extra.self == EmptyView.self)
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

extension MetricsView where Extra == EmptyView {
    init(group: PointGroup<T>, formatter: KeyPath<T, String>, period: Period) {
        self.init(group: group, formatter: formatter, period: period) { _ in EmptyView() }
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
