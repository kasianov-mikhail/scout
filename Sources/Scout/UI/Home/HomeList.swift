//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeList: View {
    @Environment(\.database) var database
    @AppStorage("scout_home_section") var section = HomeSection.sessions

    @StateObject var activities = ActivityProvider()
    @StateObject var sessions = StatProvider(eventName: "Session", periods: Period.summary)
    @StateObject var crashes = StatProvider(eventName: "Crash", periods: Period.summary)
    @StateObject var releases = ReleaseHealthProvider()
    @StateObject var logs = HomeLogProvider()
    @StateObject var devices = DevicesProvider()

    @State var showReleaseHealth = false

    var body: some View {
        if let error = HomeErrorView(providers: [sessions, crashes, activities, logs, releases, devices]) {
            error
        } else {
            List {
                SegmentStrip(selection: $section, tint: \.color, title: \.title)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    .listRowSeparator(.hidden)

                switch section {
                case .sessions:
                    HomeStatSection(section: .sessions, stat: sessions)
                case .crashes:
                    HomeStatSection(section: .crashes, stat: crashes)
                case .users:
                    HomeActivitySection(activity: activities)
                }

                HomeLogSection(log: logs, devices: devices)
                HomeReleaseSection(provider: releases, showReleaseHealth: $showReleaseHealth)
            }
            .navigationDestination(isPresented: $showReleaseHealth) {
                ReleaseHealthView(provider: releases)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .autoRefresh(rotating: [
                { await sessions.fetchLatest(in: database) },
                { await crashes.fetchLatest(in: database) },
                { await activities.fetchLatest(in: database) },
                { await logs.fetchLatest(in: database) },
                { await releases.fetchLatest(in: database) },
                { await devices.fetchLatest(in: database) },
            ])
        }
    }
}

#Preview {
    let activities = ActivityProvider()
    activities.result = .success(.samples)

    let sessions = StatProvider(eventName: "Session", periods: Period.summary)
    sessions.result = .success([.sample(name: "Session")])

    let crashes = StatProvider(eventName: "Crash", periods: Period.summary)
    crashes.result = .success([.sample(name: "Crash")])

    let releases = ReleaseHealthProvider()
    releases.result = .success(.samples)

    @MainActor func makeLogs() -> HomeLogProvider {
        let provider = HomeLogProvider()
        let initialPeriod = provider.period

        for period in Period.allCases {
            provider.period = period
            provider.result = .success(HomeLogProvider.sample(for: period))
        }

        provider.period = initialPeriod
        return provider
    }

    let logs = makeLogs()

    let devices = DevicesProvider()
    devices.result = .success(.samples)

    return NavigationStack {
        HomeList(
            activities: activities,
            sessions: sessions,
            crashes: crashes,
            releases: releases,
            logs: logs,
            devices: devices
        )
        .navigationTitle(en: "Home")
    }
    .environmentObject(Tint())
}
