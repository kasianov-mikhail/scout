//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeContent: View {
    @Environment(\.database) var database

    @StateObject var activity = ActivityProvider()
    @StateObject var sessionStat = StatProvider(eventName: "Session", periods: Period.sessions)

    var body: some View {
        List {
            logSection
            activitySection
            sessionSection
            crashSection
        }
        .listStyle(.plain)
    }

    private var logSection: some View {
        Section {
            Group {
                Row {
                    Text("Events")
                    Spacer()
                } destination: {
                    AnalyticsView()
                }
                Row {
                    Text("Metrics")
                    Spacer()
                } destination: {
                    MetricsList().navigationTitle("Metrics")
                }
            }
            .foregroundStyle(.blue)
        } header: {
            Header(title: "Log")
        }
    }

    private var activitySection: some View {
        Section {
            ForEach(ActivityPeriod.allCases) { period in
                ActivityRow(
                    period: period,
                    activity: activity
                )
            }
            .foregroundStyle(.green)
        } header: {
            Header(title: "Users").task {
                await activity.fetchIfNeeded(in: database)
            }
        }
    }

    private var sessionSection: some View {
        Section {
            let statConfig = StatConfig(
                title: "Sessions",
                color: .purple,
                showList: false
            )
            ForEach(Period.sessions) { period in
                StatRow(
                    config: statConfig,
                    period: period,
                    stat: sessionStat
                )
            }
        } header: {
            Header(title: "Sessions").task {
                await sessionStat.fetchIfNeeded(in: database)
            }
        }
    }

    private var crashSection: some View {
        Section {
            Row {
                Text("All Crashes")
                Spacer()
            } destination: {
                CrashListView()
            }
            .foregroundStyle(.red)
        } header: {
            Header(title: "Crashes")
        }
    }
}
