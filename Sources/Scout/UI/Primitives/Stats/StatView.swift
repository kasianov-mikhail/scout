//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
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

            ProviderView(provider: stat) { data in
                RangeControl(extent: $extent)

                List {
                    let points = data.flatMap(\.points)
                    let segment = extent.segment(from: points)

                    ComparableChart(segment: segment, points: points, extent: extent, color: color, isComparing: isComparing)
                        .listRowSeparator(.hidden, edges: .top)
                        .listRowSeparator(showList ? .visible : .hidden, edges: .bottom)

                    ComparisonToggle(isOn: $isComparing)
                        .disabled(!extent.canCompare(points: points, segment: segment))

                    if showList {
                        total(count: segment.total)
                    }
                }
                .listStyle(.plain)
                .scrollDisabled(true)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        ChartExportButton(title: stat.eventName, rangeLabel: extent.domain.label(using: rangeDateFormatter)) {
                            ChartView(segment: extent.segment(from: data.flatMap(\.points)), timing: extent)
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
