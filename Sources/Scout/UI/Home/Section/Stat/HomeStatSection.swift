//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeStatSection: View {
    let section: HomeSection

    @ObservedObject var activity: ActivityProvider
    @ObservedObject var sessionStat: StatProvider
    @ObservedObject var crashStat: StatProvider

    var body: some View {
        sectionRows
    }

    @ViewBuilder
    private var sectionRows: some View {
        switch section {
        case .sessions:
            statRows(for: sessionStat, section: .sessions)
        case .crashes:
            statRows(for: crashStat, section: .crashes)
        case .users:
            activityRows
        }
    }

    private var activityRows: some View {
        ForEach(Array(ActivityPeriod.allCases.enumerated()), id: \.element) { index, period in
            ActivityRow(
                period: period,
                color: HomeSection.users.color,
                systemImage: HomeSection.users.systemImage,
                activity: activity
            )
            .listRowSeparator(index == 0 ? .hidden : .automatic, edges: .top)
        }
    }

    private func statRows(for stat: StatProvider, section: HomeSection) -> some View {
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
