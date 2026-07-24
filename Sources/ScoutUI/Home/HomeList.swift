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
                statView
            case .log:
                LogView(period: period, log: logs, devices: devices)
            case .releaseHealth:
                ReleaseHealthView(provider: releases)
            case .alerts:
                AlertListView(provider: alerts)
            }
        }
        .rotatingProviders(
            first: [alerts, releases],
            later: [sessions, activities, logs, devices]
        )
    }

    private var statView: some View {
        StatView(showList: false, extent: ChartExtent(period: period), stat: sessions)
            .environment(\.chartColor, .purple)
            .navigationTitle(en: "Sessions")
    }
}

#Preview("Loading") {
    NavigationStack {
        HomeList(
            path: .constant([]),
            activities: .init(),
            retention: .init(),
            sessions: .init(eventName: "Session", periods: Period.summary),
            releases: .init().holding(.samples),
            logs: .init(),
            devices: .init(),
            alerts: .init().holding([.firingSample, .armedSample])
        )
        .navigationTitle(en: "Home")
    }
    .environmentObject(Tint())
}

#Preview("Full") {
    NavigationStack {
        HomeList(
            path: .constant([]),
            activities: .init().holding(.samples),
            retention: .init().holding(.samples),
            sessions: .init(eventName: "Session", periods: Period.summary).holding(.samples),
            releases: .init().holding(.samples),
            logs: .init().holding(acrossAllPeriods: MetricSeries.samples(for: .today)),
            devices: .init().holding(.sample),
            alerts: .init().holding([.firingSample, .armedSample])
        )
        .navigationTitle(en: "Home")
    }
    .environmentObject(Tint())
}

#Preview("Empty") {
    NavigationStack {
        HomeList(
            path: .constant([]),
            activities: .init().holding([]),
            retention: .init().holding([]),
            sessions: .init(eventName: "Session", periods: Period.summary).holding([]),
            releases: .init().holding([]),
            logs: .init().holding(acrossAllPeriods: []),
            devices: .init().holding(.empty),
            alerts: .init().holding([])
        )
        .navigationTitle(en: "Home")
    }
    .environmentObject(Tint())
}
