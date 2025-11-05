//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import CloudKit
import SwiftUI

struct StatView: View {
    struct Config {
        let title: String
        let color: Color
        let showList: Bool
    }

    let config: Config

    @State var extent: ChartExtent<Period>
    @ObservedObject var stat: StatProvider
    @EnvironmentObject var tint: Tint

    init(config: Config, stat: StatProvider, period: Period) {
        self.config = config
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
                        .foregroundStyle(config.color)
                        .listRowSeparator(config.showList ? .visible : .hidden, edges: .bottom)

                    if config.showList {
                        total(count: segment.total)
                    }
                }
                .listStyle(.plain)
                .scrollDisabled(true)
            }
        }
        .navigationTitle(config.title)
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

// MARK: -

extension StatView.Config: CustomDebugStringConvertible {
    var debugDescription: String {
        "StatView.Configuration(title: \(title), color: \(color), showList: \(showList))"
    }
}
