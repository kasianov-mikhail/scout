//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeList: View {
    @Environment(\.database) var database
    @AppStorage("scout_home_period") var period = Period.today

    @Binding var path: [HomeDestination]

    @StateObject var activities = ActivityProvider()
    @StateObject var sessions = StatProvider(eventName: "Session", periods: Period.summary)
    @StateObject var releases = ReleaseHealthProvider()
    @StateObject var logs = HomeLogProvider()
    @StateObject var devices = DevicesProvider()

    var body: some View {
        if let error = HomeErrorView(providers: [sessions, activities, logs, releases, devices]) {
            error
        } else {
            List {
                SegmentStrip(selection: $period, distribution: .justified, title: \.shortTitle)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    .listRowSeparator(.hidden)

                HStack(spacing: 24) {
                    Button {
                        path.append(.activity)
                    } label: {
                        MetricColumn(
                            title: period.activityPeriod?.acronym ?? "Users",
                            image: "person.2",
                            color: .green,
                            summary: activitySummary
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(period.activityPeriod == nil)

                    Button {
                        path.append(.sessions)
                    } label: {
                        MetricColumn(
                            title: "Sessions",
                            image: "clock",
                            color: .purple,
                            summary: sessionSummary
                        )
                    }
                    .buttonStyle(.plain)
                }
                .listRowSeparator(.hidden)

                HomeLogSection(period: period, log: logs, devices: devices) {
                    path.append(.log)
                }
                HomeReleaseSection(provider: releases) {
                    path.append(.releaseHealth)
                }
            }
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .activity:
                    activityDestination
                case .sessions:
                    sessionDestination
                case .log:
                    LogView(period: period, log: logs, devices: devices)
                case .releaseHealth:
                    ReleaseHealthView(provider: releases)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .autoRefresh(rotating: [
                { await sessions.fetchLatest(in: database) },
                { await activities.fetchLatest(in: database) },
                { await logs.fetchLatest(in: database) },
                { await releases.fetchLatest(in: database) },
                { await devices.fetchLatest(in: database) },
            ])
        }
    }

    @ViewBuilder
    private var activityDestination: some View {
        if let activityPeriod = period.activityPeriod {
            ActivityView(activity: activities, period: activityPeriod)
        }
    }

    private var sessionDestination: some View {
        StatView(showList: false, extent: ChartExtent(period: period), stat: sessions)
            .environment(\.chartColor, .purple)
            .navigationTitle(en: "Sessions")
    }

    private var activitySummary: MetricSummary? {
        guard let activityPeriod = period.activityPeriod else {
            return nil
        }
        guard let points = try? activities.result?.get() else {
            return .loading
        }
        return MetricSummary(levels: points.points(on: activityPeriod), period: period)
    }

    private var sessionSummary: MetricSummary {
        guard let matrices = try? sessions.result?.get() else {
            return .loading
        }
        return MetricSummary(points: matrices.flatMap(\.points), period: period)
    }
}

#Preview {
    let activities = ActivityProvider()
    activities.result = .success(.samples)

    let sessions = StatProvider(eventName: "Session", periods: Period.summary)
    sessions.result = .success([.sample(name: "Session")])

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
            sessions: sessions,
            releases: releases,
            logs: logs,
            devices: devices
        )
        .navigationTitle(en: "Home")
    }
    .environmentObject(Tint())
}
