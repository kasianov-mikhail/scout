//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeContent: View {
    @Environment(\.database) var database

    @State private var section = HomeSection.sessions

    @StateObject var activity = ActivityProvider()
    @StateObject var sessionStat = StatProvider(eventName: "Session", periods: Period.summary)
    @StateObject var crashStat = StatProvider(eventName: "Crash", periods: Period.summary)

    var body: some View {
        List {
            statSection
            HomeLogSection()
        }
        .listStyle(.plain)
    }

    private var statSection: some View {
        Section {
            sectionRows
        } header: {
            HomeSectionPicker(selection: $section)
                .padding(.bottom, 4)
                .task(id: section) {
                    switch section {
                    case .sessions:
                        await sessionStat.fetchIfNeeded(in: database)
                    case .crashes:
                        await crashStat.fetchIfNeeded(in: database)
                    case .users:
                        await activity.fetchIfNeeded(in: database)
                    }
                }
        }
    }

    @ViewBuilder
    private var sectionRows: some View {
        switch section {
        case .sessions:
            statRows(for: sessionStat, section: .sessions)
        case .crashes:
            statRows(for: crashStat, section: .crashes)
        case .users:
            ForEach(ActivityPeriod.allCases) { period in
                ActivityRow(
                    period: period,
                    color: HomeSection.users.color,
                    systemImage: HomeSection.users.systemImage,
                    activity: activity
                )
            }
        }
    }

    private func statRows(for stat: StatProvider, section: HomeSection) -> some View {
        ForEach(Period.summary) { period in
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
        }
    }
}

#Preview {
    NavigationStack {
        HomeContent().navigationTitle("Home")
    }
}
