//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
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
    @StateObject var alerts = AlertProvider(notifier: AlertNotifier())

    var body: some View {
        InsetList {
            SegmentStrip(
                selection: $period,
                distribution: .justified,
                title: \.shortTitle
            )
            .padding(.top, 8)
            .listRowSeparator(.hidden)

            HomeAlertSection(
                alerts: alerts,
                path: $path
            )
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
        .scrollContentBackground(.hidden)
        .globalSearch()
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
            case .alerts:
                AlertListView(provider: alerts)
            }
        }
        .rotatingProviders([sessions, activities, logs, releases, devices, alerts])
        .loadingGate([alerts, releases])
    }
}

#Preview("Populated") {
    NavigationStack {
        HomeList(alerts: [.firingSample, .armedSample], releases: .samples)
            .navigationTitle(en: "Home")
    }
    .environmentObject(Tint())
}

#Preview("Skeletons") {
    NavigationStack {
        HomeList(alerts: nil, releases: nil)
            .navigationTitle(en: "Home")
    }
    .environmentObject(Tint())
}

#Preview("Empty") {
    NavigationStack {
        HomeList(alerts: [], releases: [])
            .navigationTitle(en: "Home")
    }
    .environmentObject(Tint())
}
