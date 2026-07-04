//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeContent: View {
    @Environment(\.database) var database

    @AppStorage("scout_home_section") private var section = HomeSection.sessions

    @StateObject private var activity: ActivityProvider
    @StateObject private var sessionStat: StatProvider
    @StateObject private var crashStat: StatProvider
    @StateObject private var releaseProvider: ReleaseHealthProvider
    @State private var showReleaseHealth = false

    init(
        activity: ActivityProvider = ActivityProvider(),
        sessionStat: StatProvider = StatProvider(eventName: "Session", periods: Period.summary),
        crashStat: StatProvider = StatProvider(eventName: "Crash", periods: Period.summary),
        releaseProvider: ReleaseHealthProvider = ReleaseHealthProvider()
    ) {
        self._activity = StateObject(wrappedValue: activity)
        self._sessionStat = StateObject(wrappedValue: sessionStat)
        self._crashStat = StateObject(wrappedValue: crashStat)
        self._releaseProvider = StateObject(wrappedValue: releaseProvider)
    }

    var body: some View {
        VStack(spacing: 0) {
            HomeSectionPicker(selection: $section)
                .padding(.horizontal)
                .padding(.top, 8)
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

            List {
                HomeStatSection(
                    section: section,
                    activity: activity,
                    sessionStat: sessionStat,
                    crashStat: crashStat
                )
                HomeLogSection()
                HomeReleaseSection(provider: releaseProvider, showReleaseHealth: $showReleaseHealth)
            }
            .navigationDestination(isPresented: $showReleaseHealth) {
                ReleaseHealthView(provider: releaseProvider)
            }
            .listStyle(.plain)
            .imageScale(.medium)
            .scrollContentBackground(.hidden)
        }
        .background {
            Rectangle()
                .fill(.background)
                .ignoresSafeArea()
        }
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        HomeContent(releaseProvider: .fixture()).navigationTitle("Home")
    }
}
