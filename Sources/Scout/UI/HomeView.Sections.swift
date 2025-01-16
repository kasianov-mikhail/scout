//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

// MARK: - Event Section

extension HomeView {
    struct EventSection: View {
        var body: some View {
            Header(title: "Events")

            Row {
                Text("See All").foregroundStyle(.blue)
                Spacer()
            } destination: {
                AnalyticsView()
            }
        }
    }
}

// MARK: - Active User Section

extension HomeView {
    struct ActiveUserSection: View {
        var body: some View {
            Header(title: "Users")

            ForEach(UserPeriod.allCases) { period in
                Row {
                    Text(period.title)
                    Spacer()
                    Redacted(length: 8)
                } destination: {
                    Placeholder(text: "Coming Soon").navigationTitle("Active Users")
                }
            }
            .foregroundStyle(.green)
        }
    }
}

// MARK: - Session Section

extension HomeView {
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
