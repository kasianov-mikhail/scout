//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import SwiftUI

struct StatView: View {
    let title: String
    let color: Color
    let showList: Bool

    @State var extent: ChartExtent<Period>
    @ObservedObject var stat: StatProvider
    @EnvironmentObject var tint: Tint

    init(title: String, color: Color, showList: Bool, stat: StatProvider, period: Period) {
        self.title = title
        self.color = color
        self.showList = showList
        self.stat = stat
        self._extent = State(wrappedValue: ChartExtent(period: period))
    }

    var body: some View {
        VStack(spacing: 0) {
            PeriodPicker(extent: $extent, periods: stat.periods)

            ProviderView(provider: stat) { data in
                RangeControl(extent: $extent)

                List {
                    let points = data.flatMap(\.points)
                    let segment = extent.segment(from: points)

                    ChartView(segment: segment, timing: extent)
                        .foregroundStyle(color)
                        .listRowSeparator(showList ? .visible : .hidden, edges: .bottom)

                    if showList {
                        total(count: segment.total)
                    }
                }
                .listStyle(.plain)
                .scrollDisabled(true)
            }
        }
        .navigationTitle(title)
        .onAppear {
            tint.value = nil
        }
    }

    func total(count: Int) -> some View {
        ZStack {
            HStack {
                Text("Events")
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

// MARK: - Preview

#Preview("StatView") {
    let stat = StatProvider(eventName: "app_launch", periods: Period.allCases)
    stat.result = .success([])
    return NavigationStack {
        StatView(
            title: "App Launch",
            color: .blue,
            showList: true,
            stat: stat,
            period: .yesterday
        )
        .environmentObject(Tint())
    }
}
