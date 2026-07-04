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

    var body: some View {
        List {
            HomeSectionPicker(selection: $section)
                .padding(.top, 8)
                .padding(.bottom, 4)
                .listRowSeparator(.hidden)
                .onAppear { fetch(section) }
                .onChange(of: section) { fetch($0) }

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
        .background {
            Rectangle()
                .fill(.background)
                .ignoresSafeArea()
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .onboardingSheet()
    }

    private func fetch(_ section: HomeSection) {
        Task {
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

extension HomeContent {
    init(activity: ActivityProvider, sessionStat: StatProvider, crashStat: StatProvider, releaseProvider: ReleaseHealthProvider) {
        self._activity = StateObject(wrappedValue: activity)
        self._sessionStat = StateObject(wrappedValue: sessionStat)
        self._crashStat = StateObject(wrappedValue: crashStat)
        self._releaseProvider = StateObject(wrappedValue: releaseProvider)
    }
}

#Preview {
    NavigationStack {
        HomeContent(
            activity: ActivityProvider(),
            sessionStat: StatProvider(eventName: "Session", periods: Period.summary),
            crashStat: StatProvider(eventName: "Crash", periods: Period.summary),
            releaseProvider: .fixture()
        )
        .navigationTitle("Home")
    }
}
