//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension HomeView {
    struct LogSection: View {
        var body: some View {
            Header(title: "Log")

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
        }
    }

    struct ActivitySection: View {
        @EnvironmentObject private var database: DatabaseController
        @StateObject private var activity = ActivityProvider()

        var body: some View {
            Header(title: "Users").task {
                await activity.fetchIfNeeded(in: database)
            }
            ForEach(ActivityPeriod.allCases) { period in
                ActivityRow(
                    period: period,
                    activity: activity
                )
            }
            .foregroundStyle(.green)
        }
    }

    struct SessionSection: View {
        @EnvironmentObject private var database: DatabaseController

        @StateObject private var stat = StatProvider(
            eventName: "Session",
            periods: Period.sessions
        )

        var body: some View {
            Header(title: "Sessions").task {
                await stat.fetchIfNeeded(in: database)
            }
            let statConfig = StatConfig(
                title: "Sessions",
                color: .purple,
                showList: false
            )
            ForEach(Period.sessions) { period in
                StatRow(
                    config: statConfig,
                    period: period,
                    stat: stat
                )
            }
        }
    }
}
