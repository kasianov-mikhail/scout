//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import Scout
import SwiftUI

struct StatView: View {
    let showList: Bool

    @State var extent: ChartExtent<Period>
    @State private var isComparing = false
    @ObservedObject var stat: StatProvider
    @Environment(\.chartColor) var color

    var body: some View {
        VStack(spacing: 0) {
            PeriodPicker(extent: $extent, periods: stat.periods)

            ProviderView(provider: stat) { points in
                let segment = extent.segment(from: points)

                RangeControl(extent: $extent)

                List {
                    ComparableChart(
                        segment: segment, points: points, extent: extent, color: color, isComparing: isComparing
                    )
                    .listRowSeparator(.hidden, edges: .top)
                    .listRowSeparator(showList ? .visible : .hidden, edges: .bottom)

                    ComparisonToggle(isOn: $isComparing)
                        .disabled(!extent.canCompare(points: points, segment: segment))

                    if showList {
                        total(count: segment.total)
                    }

                    Header(title: "Weekly Pattern") {
                        Text(verbatim: "Last 4 weeks")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .listRowSeparator(.hidden)

                    HeatmapView(
                        grid: HeatmapGrid(
                            points: points,
                            range: HeatmapGrid.recentRange(weeks: 4),
                            calendar: .utc
                        )
                    )
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        ChartExportButton(
                            title: stat.eventName, rangeLabel: extent.domain.label(using: rangeDateFormatter)
                        ) {
                            ChartView(segment: segment, timing: extent)
                                .foregroundStyle(color)
                        }
                    }
                }
            }
        }
        .resetsTint()
    }

    func total(count: Int) -> some View {
        Row {
            Text(verbatim: "Events")
            Spacer()
            RedactedText(count: count)
        } destination: {
            EventStatList(eventName: stat.eventName, range: extent.domain)
        }
        .foregroundColor(.blue)
    }
}

extension EnvironmentValues {
    @Entry var chartColor: Color = .blue
}

#Preview("StatView") {
    let stat = StatProvider(eventName: "app_launch", periods: Period.allCases)
    stat.result = .success([])

    return NavigationStack {
        StatView(
            showList: true,
            extent: ChartExtent(period: .yesterday),
            stat: stat
        )
        .navigationTitle(en: "App Launch")
        .environmentObject(Tint())
    }
}
