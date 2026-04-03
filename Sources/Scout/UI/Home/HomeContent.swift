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
    @StateObject var sessionStat = StatProvider(eventName: "Session", periods: Period.summary)
    @StateObject var crashStat = StatProvider(eventName: "Crash", periods: Period.summary)

    var body: some View {
        List {
            logSection
            crashSection
            activitySection
            sessionSection
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

    private var crashSection: some View {
        Section {
            let statConfig = StatConfig(
                title: "Crashes",
                color: .red,
                showList: false
            )
            ForEach(Period.summary) { period in
                StatRow(
                    config: statConfig,
                    period: period,
                    stat: crashStat
                )
            }

            Row {
                Text("All")
                Spacer()
            } destination: {
                CrashListView()
            }
            .foregroundStyle(.red)
        } header: {
            Header(title: "Crashes").task {
                await crashStat.fetchIfNeeded(in: database)
            }
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
            ForEach(Period.summary) { period in
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
}
