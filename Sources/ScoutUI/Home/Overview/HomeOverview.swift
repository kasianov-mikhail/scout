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
                    await providers.fetchIfFailed(in: database)
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
                sections(snapshot)
            } else {
                placeholderSections
            }
        }
        .scrollIndicators(.hidden)
    }

    private func sections(_ snapshot: HomeSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HomeAlertSection(
                history: snapshot.alerts,
                alerts: alerts,
                path: $path
            )
            .loadingInk(isLoading: isLoading, delay: 0.05)

            HomeActivitySection(
                users: snapshot.users,
                activity: activities,
                zoom: zoom,
                path: $path
            )
            .loadingInk(isLoading: isLoading, delay: 0.10)

            HomeTelemetrySection(
                items: snapshot.telemetry,
                path: $path
            )
            .loadingInk(isLoading: isLoading, delay: 0.20)

            HomeReleaseSection(
                adoption: snapshot.releases,
                releases: releases,
                zoom: zoom,
                path: $path
            )
            .loadingInk(isLoading: isLoading, delay: 0.30)

            HomeRetentionSection(
                weeks: snapshot.retention,
                retention: retention,
                path: $path
            )
            .loadingInk(isLoading: isLoading, delay: 0.40)
        }
        .transition(.opacity)
    }

    private var placeholderSections: some View {
        VStack(alignment: .leading, spacing: 0) {
            HomeAlertSection.Placeholder()
            HomeActivitySection.Placeholder()
            HomeTelemetrySection.Placeholder()
            HomeReleaseSection.Placeholder()
            HomeRetentionSection.Placeholder()
        }
        .transition(.opacity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Loading"))
    }
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
