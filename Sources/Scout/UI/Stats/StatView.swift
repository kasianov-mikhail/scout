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
    @State var comparison: ChartComparison? = nil
    @ObservedObject var stat: StatProvider
    @EnvironmentObject var tint: Tint
    @Environment(\.chartColor) var color

    var body: some View {
        VStack(spacing: 0) {
            PeriodPicker(extent: $extent, periods: stat.periods)

            ProviderView(provider: stat) { data in
                RangeControl(extent: $extent)
                ComparisonPicker(comparison: $comparison)

                List {
                    let points = data.flatMap(\.points)

                    ComparisonChartView(points: points, extent: extent, comparison: comparison)
                        .foregroundStyle(color)
                        .listRowSeparator(showList ? .visible : .hidden, edges: .bottom)

                    if showList {
                        total(count: extent.segment(from: points).total)
                    }
                }
                .listStyle(.plain)
                .scrollDisabled(comparison == nil)
            }
        }
        .onAppear {
            tint.value = nil
        }
    }

    func total(count: Int) -> some View {
        ZStack {
            HStack {
                Text(verbatim: "Events")
                Spacer()
                Text(count == 0 ? "—" : "\(count)")
            }
            .foregroundColor(.blue)

            NavigationLink {
                EventStatList(eventName: stat.eventName, range: extent.domain)
            } label: {
                EmptyView()
            }
            .opacity(0)
        }
        .alignmentGuide(.listRowSeparatorTrailing) { dimension in
            dimension[.trailing]
        }
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
