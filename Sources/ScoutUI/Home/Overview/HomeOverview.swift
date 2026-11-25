//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI
import UserNotifications

struct HomeOverview: View {
    var snapshot: HomeSnapshot? = nil

    @Binding var path: NavigationPath

    @Namespace private var zoom

    @StateObject var activities = ActivityProvider()
    @StateObject var retention = RetentionProvider()
    @StateObject var sessions = StatProvider(subject: .sessions)
    @StateObject var releases = ReleaseHealthProvider()
    @StateObject var logs = HomeLogProvider(period: .today)
    @StateObject var devices = DevicesProvider()
    @StateObject var alerts = AlertProvider(permission: NotificationPermission(center: UNUserNotificationCenter.current()))

    @Environment(\.database) private var database

    var body: some View {
        Group {
            if let snapshot {
                list(snapshot)
            } else if let error = providers.compactMap(\.error).first {
                ErrorView(description: error.localizedDescription) {
                    for provider in providers {
                        await provider.fetchIfFailed(in: database)
                    }
                }
            } else {
                list(live)
            }
        }
        .animation(.easeOut(duration: 0.2), value: isLoading)
        .fetchTask(snapshot == nil ? providers : [])
    }

    private var isLoading: Bool {
        snapshot == nil && providers.contains(where: \.isLoading)
    }

    private var providers: [any Provider] {
        [alerts, activities, sessions, releases, retention, logs, devices]
    }

    private var live: HomeSnapshot? {
        HomeSnapshot(
            alerts: alerts.result,
            activity: activities.result,
            sessions: sessions.result,
            releases: releases.result,
            retention: retention.result,
            devices: devices.result,
            report: logs.report
        )
    }

    private func list(_ snapshot: HomeSnapshot?) -> some View {
        ScrollView {
            if let snapshot {
                loadedSections(snapshot)
            } else {
                placeholderSections
            }
        }
        .scrollIndicators(.hidden)
        .navigationDestination(for: HomeDestination.self) { destination in
            switch destination {
            case .retention:
                RetentionView(provider: retention)
            case .releaseHealth:
                ReleaseHealthView(provider: releases).zoomTransition(destination, in: zoom)
            case .alerts:
                AlertListView(provider: alerts)
            case .telemetry(let category):
                LogDestination(category: category)
            case .resources:
                ResourceListView()
            }
        }
    }

    private func loadedSections(_ snapshot: HomeSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HomeAlertSection(history: snapshot.alerts) {
                path.append(HomeDestination.alerts)
            }
            .padding(.horizontal, .gutter)
            .loadingInk(isLoading: isLoading, delay: 0.05)

            HomeActivitySection(
                users: snapshot.users,
                activity: activities,
                zoom: zoom,
                path: $path
            )
            .loadingInk(isLoading: isLoading, delay: 0.10)

            HomeTelemetrySection(items: snapshot.telemetry) { kind in
                switch kind {
                case .events:
                    path.append(HomeDestination.telemetry(.events))
                case .crashes:
                    path.append(HomeDestination.telemetry(.crashes))
                case .metrics:
                    path.append(HomeDestination.telemetry(.metrics))
                case .hangs:
                    path.append(HomeDestination.telemetry(.hangs))
                case .network:
                    path.append(HomeDestination.telemetry(.network))
                case .resources:
                    path.append(HomeDestination.resources)
                }
            }
            .loadingInk(isLoading: isLoading, delay: 0.20)

            HomeReleaseSection(adoption: snapshot.releases) {
                path.append(HomeDestination.releaseHealth)
            }
            .zoomSource(HomeDestination.releaseHealth, in: zoom)
            .contentShape(Rectangle())
            .onTapGesture {
                path.append(HomeDestination.releaseHealth)
            }
            .loadingInk(isLoading: isLoading, delay: 0.30)

            HomeRetentionSection(weeks: snapshot.retention) {
                path.append(HomeDestination.retention)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                path.append(HomeDestination.retention)
            }
            .loadingInk(isLoading: isLoading, delay: 0.40)
        }
        .transition(.opacity)
    }

    private var placeholderSections: some View {
        VStack(alignment: .leading, spacing: 0) {
            HomeAlertSection(history: nil) {}.padding(.horizontal, .gutter)
            HomeActivitySection(users: nil, activity: activities, zoom: zoom, path: $path)
            HomeTelemetrySection(items: nil) { _ in }
            HomeReleaseSection(adoption: nil) {}
            HomeRetentionSection(weeks: nil) {}
        }
        .transition(.opacity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }
}

private enum HomeDestination: Hashable {
    case retention
    case releaseHealth
    case alerts
    case telemetry(LogCategory)
    case resources
}

#Preview("Home") {
    NavigationStack {
        HomeOverview(snapshot: .sample, path: .constant(NavigationPath()))
            .navigationTitle(en: "Home")
            .inlineNavigationTitle(divider: nil)
    }
    .environmentObject(Tint())
}

#Preview("Empty") {
    NavigationStack {
        HomeOverview(snapshot: .empty, path: .constant(NavigationPath()))
            .navigationTitle(en: "Home")
            .inlineNavigationTitle(divider: nil)
    }
    .environmentObject(Tint())
}

#Preview("Loading") {
    NavigationStack {
        HomeOverview(path: .constant(NavigationPath()))
            .navigationTitle(en: "Home")
            .inlineNavigationTitle(divider: nil)
    }
}
