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
    var eventChanges: EventChanges? = nil

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
        content
            .animation(.easeOut(duration: 0.2), value: isLoading)
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
        } else {
            list(live)
        }
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
            case .activity:
                ActivityView(activity: activities).zoomTransition(destination, in: zoom)
            case .retention:
                RetentionView(provider: retention)
            case .releaseHealth:
                ReleaseHealthView(provider: releases).zoomTransition(destination, in: zoom)
            case .alerts:
                AlertListView(provider: alerts)
            case .telemetry(let category):
                LogDestination(category: category, eventChanges: eventChanges)
            case .resources:
                ResourceListView()
            }
        }
    }

    private func loadedSections(_ snapshot: HomeSnapshot) -> some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            HomeAlertSection(history: snapshot.alerts) {
                path.append(.alerts)
            }
            .padding(.horizontal, .gutter)
            .loadingInk(isLoading: isLoading, delay: 0.05)

            HomeActiveUsersSection(users: snapshot.users) { _ in
                path.append(.activity)
            }
            .zoomSource(HomeDestination.activity, in: zoom)
            .contentShape(Rectangle())
            .onTapGesture { path.append(.activity) }
            .loadingInk(isLoading: isLoading, delay: 0.10)

            HomeTelemetrySection(items: snapshot.telemetry) { kind in
                switch kind {
                case .events:
                    path.append(.telemetry(.events))
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
            .loadingInk(isLoading: isLoading, delay: 0.20)

            HomeReleaseSection(adoption: snapshot.releases) {
                path.append(.releaseHealth)
            }
            .zoomSource(HomeDestination.releaseHealth, in: zoom)
            .contentShape(Rectangle())
            .onTapGesture { path.append(.releaseHealth) }
            .loadingInk(isLoading: isLoading, delay: 0.30)

            HomeRetentionSection(weeks: snapshot.retention) {
                path.append(.retention)
            }
            .contentShape(Rectangle())
            .onTapGesture { path.append(.retention) }
            .loadingInk(isLoading: isLoading, delay: 0.40)
        }
        .transition(.opacity)
    }

    private var placeholderSections: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            HomeAlertSection(history: nil) {}
                .padding(.horizontal, .gutter)
            HomeActiveUsersSection(users: nil) { _ in }
            HomeTelemetrySection(items: nil) { _ in }
            HomeReleaseSection(adoption: nil) {}
            HomeRetentionSection(weeks: nil) {}
        }
        .transition(.opacity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
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

#Preview("Empty") {
    NavigationStack {
        HomeList(snapshot: .empty, path: .constant([]))
            .navigationTitle(en: "Home")
            .inlineNavigationTitle()
    }
    .environmentObject(Tint())
}

#Preview("Loading") {
    NavigationStack {
        HomeList(path: .constant([]))
            .navigationTitle(en: "Home")
            .inlineNavigationTitle()
    }
}
