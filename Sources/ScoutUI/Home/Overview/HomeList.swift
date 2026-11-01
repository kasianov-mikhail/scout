//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI
import UserNotifications

struct HomeList: View {
    let snapshot: HomeSnapshot = .sample

    @Binding var path: [HomeDestination]

    @StateObject var activities = ActivityProvider()
    @StateObject var retention = RetentionProvider()
    @StateObject var sessions = StatProvider(subject: .sessions)
    @StateObject var releases = ReleaseHealthProvider()
    @StateObject var logs = HomeLogProvider()
    @StateObject var alerts = AlertProvider(permission: NotificationPermission(center: UNUserNotificationCenter.current()))

    var body: some View {
        InsetList {
            HomeAlertSection(history: snapshot.alerts) {
                path.append(.alerts)
            }
            HomeActiveUsersSection(users: snapshot.users) { kind in
                switch kind {
                case .sessions:
                    path.append(.sessions)
                case .dau, .devices:
                    path.append(.activity)
                }
            }
            HomeTelemetrySection(items: snapshot.telemetry) { kind in
                switch kind {
                case .events:
                    path.append(.log)
                case .crashes:
                    path.append(.telemetry(.crashes))
                case .metrics:
                    path.append(.telemetry(.metrics))
                case .hangs:
                    path.append(.telemetry(.hangs))
                case .network:
                    path.append(.telemetry(.network))
                case .resources:
                    path.append(.resources)
                }
            }
            HomeReleaseSection(adoption: snapshot.releases) {
                path.append(.releaseHealth)
            }
            HomeRetentionSection(weeks: snapshot.retention) {
                path.append(.retention)
            }
        }
        .scrollContentBackground(.hidden)
        .refreshingProviders(
            first: [alerts, releases, retention],
            later: [sessions, activities, logs]
        )
        .globalSearch(releases: releases)
        .navigationDestination(for: HomeDestination.self) { destination in
            switch destination {
            case .activity:
                ActivityView(activity: activities, period: Period.today.activityPeriod)
            case .retention:
                RetentionHeroChartView(provider: retention)
            case .sessions:
                statView
            case .log:
                LogView(period: .today, log: logs)
            case .releaseHealth:
                ReleaseHealthView(provider: releases)
            case .alerts:
                AlertListView(provider: alerts)
            case .telemetry(let category):
                LogDestination(category: category)
            case .resources:
                ReleaseHealthView(provider: releases)
            }
        }
    }

    private var statView: some View {
        StatView(showList: false, extent: ChartExtent(period: .today), stat: sessions)
            .environment(\.chartColor, .purple)
            .navigationTitle(en: "Sessions")
    }
}

#Preview("Home") {
    NavigationStack {
        HomeList(path: .constant([]))
            .navigationTitle(en: "Home")
    }
    .environmentObject(Tint())
}
