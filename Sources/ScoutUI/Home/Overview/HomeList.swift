//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI
import UserNotifications

struct HomeList: View {
    var snapshot: HomeSnapshot? = nil

    @Binding var path: [HomeDestination]

    @StateObject var activities = ActivityProvider()
    @StateObject var retention = RetentionProvider()
    @StateObject var sessions = StatProvider(subject: .sessions)
    @StateObject var releases = ReleaseHealthProvider()
    @StateObject var logs = HomeLogProvider(period: .today)
    @StateObject var devices = DevicesProvider()
    @StateObject var alerts = AlertProvider(permission: NotificationPermission(center: UNUserNotificationCenter.current()))

    @Environment(\.database) private var database

    @State private var ink = true
    @State private var wasLoading = false

    var body: some View {
        content
            .animation(.easeOut(duration: 0.2), value: isLoading)
            .task(id: isLoading) {
                if isLoading {
                    wasLoading = true
                    ink = false
                } else if wasLoading {
                    try? await Task.sleep(for: .milliseconds(200))
                    guard !Task.isCancelled else {
                        return
                    }
                    ink = true
                    wasLoading = false
                }
            }
            .fetchTask(snapshot == nil ? providers : [])
    }

    @ViewBuilder
    private var content: some View {
        if let snapshot {
            list(snapshot)
        } else if let error = providers.compactMap(\.error).first {
            ErrorView(description: error.localizedDescription) {
                for provider in providers {
                    await provider.fetchIfFailed(in: database)
                }
            }
        } else if isLoading {
            skeleton.transition(.opacity)
        } else if let live {
            list(live).transition(.opacity)
        }
    }

    fileprivate var skeleton: some View {
        InsetList {
            HomeAlertSection(history: nil) {}
                .padding(.top, 6)
            HomeActiveUsersSection(users: nil) { _ in }
            HomeTelemetrySection(items: nil) { _ in }
            HomeReleaseSection(adoption: nil) {}
            HomeRetentionSection(weeks: nil) {}
        }
        .scrollContentBackground(.hidden)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }

    private var isLoading: Bool {
        snapshot == nil && providers.contains(where: \.isLoading)
    }

    private var providers: [any Provider] {
        [alerts, activities, sessions, releases, retention, logs, devices]
    }

    private var live: HomeSnapshot? {
        guard case .success(let statuses)? = alerts.result, case .success(let points)? = activities.result, case .success(let sessionPoints)? = sessions.result, case .success(let releaseList)? = releases.result, case .success(let cohorts)? = retention.result, case .success(let deviceList)? = devices.result else {
            return nil
        }
        guard let report = logs.report else {
            return nil
        }

        return HomeSnapshot(
            alerts: AlertHistory(statuses: statuses),
            users: ActiveUsers(activity: points, sessions: sessionPoints, devices: deviceList),
            telemetry: [TelemetryItem](report: report, resources: releaseList),
            releases: ReleaseAdoption(releases: releaseList),
            retention: [RetentionWeek](cohorts: cohorts)
        )
    }

    private func list(_ snapshot: HomeSnapshot) -> some View {
        InsetList {
            HomeAlertSection(history: snapshot.alerts) {
                path.append(.alerts)
            }
            .padding(.top, 6)
            .homeInk(0, isInked: ink)
            HomeActiveUsersSection(users: snapshot.users) { kind in
                switch kind {
                case .sessions:
                    path.append(.sessions)
                case .dau, .devices:
                    path.append(.activity)
                }
            }
            .homeInk(1, isInked: ink)
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
            .homeInk(2, isInked: ink)
            HomeReleaseSection(adoption: snapshot.releases) {
                path.append(.releaseHealth)
            }
            .homeInk(3, isInked: ink)
            HomeRetentionSection(weeks: snapshot.retention) {
                path.append(.retention)
            }
            .homeInk(4, isInked: ink)
        }
        .scrollContentBackground(.hidden)
        .navigationDestination(for: HomeDestination.self) { destination in
            switch destination {
            case .activity:
                ActivityView(activity: activities)
            case .retention:
                RetentionView(provider: retention)
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
                ResourceListView()
            }
        }
    }

    private var statView: some View {
        StatView(showList: false, extent: ChartExtent(period: .today), stat: sessions)
            .environment(\.chartColor, .purple)
            .navigationTitle(en: "Sessions")
    }
}

private let homeInkDelays = [0.05, 0.10, 0.20, 0.30, 0.40]

extension View {
    fileprivate func homeInk(_ index: Int, isInked: Bool) -> some View {
        saturation(isInked ? 1 : 0)
            .animation(.easeOut(duration: 0.3).delay(homeInkDelays[min(index, homeInkDelays.count - 1)]), value: isInked)
    }
}

#Preview("Home") {
    NavigationStack {
        HomeList(snapshot: .sample, path: .constant([]))
            .navigationTitle(en: "Home")
            .inlineNavigationTitle()
    }
    .environmentObject(Tint())
}

#Preview("Loading") {
    NavigationStack {
        HomeList(path: .constant([])).skeleton
            .navigationTitle(en: "Home")
            .inlineNavigationTitle()
    }
}
