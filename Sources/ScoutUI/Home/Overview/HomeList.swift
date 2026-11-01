//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI
import UserNotifications

struct HomeList: View {
    @Binding var path: [HomeDestination]

    @StateObject var activities = ActivityProvider()
    @StateObject var retention = RetentionProvider()
    @StateObject var sessions = StatProvider(subject: .sessions)
    @StateObject var releases = ReleaseHealthProvider()
    @StateObject var logs = HomeLogProvider()
    @StateObject var alerts = AlertProvider(permission: NotificationPermission(center: UNUserNotificationCenter.current()))

    var body: some View {
        InsetList {
            HomeAlertSection(history: .sample) {
                path.append(.alerts)
            }
            HomeActiveUsersSection(users: .sample) { kind in
                switch kind {
                case .sessions:
                    path.append(.sessions)
                case .dau, .devices:
                    path.append(.activity)
                }
            }
            HomeTelemetrySection(items: TelemetryItem.sample) { kind in
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
            HomeReleaseSection(adoption: .sample) {
                path.append(.releaseHealth)
            }
            HomeRetentionSection(
                retention: retention,
                path: $path
            )
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

#Preview("Loading") {
    NavigationStack {
        HomeList(
            path: .constant([]),
            activities: .init(),
            retention: .init(),
            sessions: .init(subject: .sessions),
            releases: .init(.success(.samples)),
            logs: .init(),
            alerts: .init(.success([.firingSample, .armedSample]))
        )
        .navigationTitle(en: "Home")
    }
    .environmentObject(Tint())
}

#Preview("Full") {
    NavigationStack {
        HomeList(
            path: .constant([]),
            activities: .init(.success(.samples)),
            retention: .init(.success(.samples)),
            sessions: .init(.success(.samples), subject: .sessions),
            releases: .init(.success(.samples)),
            logs: .init(acrossAllPeriods: .sample(for: .today)),
            alerts: .init(.success([.firingSample, .armedSample]))
        )
        .navigationTitle(en: "Home")
    }
    .environmentObject(Tint())
}

#Preview("Empty") {
    NavigationStack {
        HomeList(
            path: .constant([]),
            activities: .init(.success([])),
            retention: .init(.success([])),
            sessions: .init(.success([]), subject: .sessions),
            releases: .init(.success([])),
            logs: .init(acrossAllPeriods: LogSnapshot(series: [], deviceCounts: [])),
            alerts: .init(.success([]))
        )
        .navigationTitle(en: "Home")
    }
    .environmentObject(Tint())
}
