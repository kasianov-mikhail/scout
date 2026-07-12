//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeStatSection: View {
    let section: HomeSection

    @ObservedObject var stat: StatProvider

    var body: some View {
        ForEach(Array(Period.summary.enumerated()), id: \.element) { index, period in
            StatRow(
                color: section.color,
                period: period,
                systemImage: section.systemImage,
                stat: stat
            ) {
                StatView(
                    showList: false,
                    extent: ChartExtent(period: period),
                    stat: stat
                )
                .environment(\.chartColor, section.color)
                .navigationTitle(en: section.title)
            }
            .listRowSeparator(index == 0 ? .hidden : .automatic, edges: .top)
        }
    }
}

#Preview {
    let stat = StatProvider(eventName: "Session", periods: Period.summary)
    stat.result = .success([.sample(name: "Session")])

    return NavigationStack {
        List {
            HomeStatSection(section: .sessions, stat: stat)
        }
        .listStyle(.plain)
    }
}
