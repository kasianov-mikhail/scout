//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeList: View {
    @AppStorage("scout_home_period") var period = Period.today

    @Binding var path: [HomeDestination]

    @StateObject var activities = ActivityProvider()
    @StateObject var retention = RetentionProvider()
    @StateObject var sessions = StatProvider(eventName: "Session", periods: Period.summary)
    @StateObject var releases = ReleaseHealthProvider()
    @StateObject var logs = HomeLogProvider()
    @StateObject var devices = DevicesProvider()

    var body: some View {
        List {
            SegmentStrip(
                selection: $period,
                distribution: .justified,
                title: \.shortTitle
            )
            .padding(.top, 8)
            .listRowSeparator(.hidden)

            HomeMetricSection(
                activities: activities,
                sessions: sessions,
                period: period,
                path: $path
            )
            HomeLogSection(
                period: period,
                log: logs,
                devices: devices,
                path: $path
            )
            HomeReleaseSection(
                releases: releases,
                path: $path
            )
            HomeRetentionSection(
                retention: retention,
                path: $path
            )
        }
        .navigationDestination(for: HomeDestination.self) { destination in
            switch destination {
            case .activity:
                ActivityView(activity: activities, period: period.activityPeriod)
            case .retention:
                RetentionHeroChartView(provider: retention)
            case .sessions:
                StatView(showList: false, extent: ChartExtent(period: period), stat: sessions)
                    .environment(\.chartColor, .purple)
                    .navigationTitle(en: "Sessions")
            case .log:
                LogView(period: period, log: logs, devices: devices)
            case .releaseHealth:
                ReleaseHealthView(provider: releases)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .rotatingProviders([sessions, activities, logs, releases, devices])
    }
}

#Preview {
    let activities = ActivityProvider()
    activities.result = .success(.samples)

    let sessions = StatProvider(eventName: "Session", periods: Period.summary)
    sessions.result = .success([.sample(name: "Session")])

    let retention = RetentionProvider()
    retention.result = .success(.samples)

    let releases = ReleaseHealthProvider()
    releases.result = .success(.samples)

    @MainActor func makeLogs() -> HomeLogProvider {
        let provider = HomeLogProvider()

        for period in Period.allCases {
            provider.period = period
            provider.result = .success(HomeLogProvider.sample(for: period))
        }

        provider.period = .today
        return provider
    }

    let logs = makeLogs()

    let devices = DevicesProvider()
    devices.result = .success(.sample)

    return NavigationStack {
        HomeList(
            path: .constant([]),
            activities: activities,
            retention: retention,
            sessions: sessions,
            releases: releases,
            logs: logs,
            devices: devices
        )
        .navigationTitle(en: "Home")
    }
    .environmentObject(Tint())
}
