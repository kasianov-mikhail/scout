//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

struct HomeMetricSection: View {
    @ObservedObject var activities: ActivityProvider
    @ObservedObject var sessions: StatProvider

    let period: Period

    @Binding var path: [HomeDestination]

    var body: some View {
        HStack(spacing: 24) {
            Button {
                path.append(.activity)
            } label: {
                MetricCard(
                    title: "Users",
                    color: .green,
                    summary: activitySummary
                )
            }
            .buttonStyle(.plain)
            .disabled(period.activityPeriod == nil)

            Button {
                path.append(.sessions)
            } label: {
                MetricCard(
                    title: "Sessions",
                    color: .purple,
                    summary: sessionSummary
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, -11)
        .listRowSeparator(.hidden)
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
        guard let points = try? sessions.result?.get() else {
            return .loading
        }
        return MetricSummary(points: points, period: period)
    }
}

#Preview {
    let activities = ActivityProvider()
    activities.result = .success(.samples)

    let sessions = StatProvider(eventName: "Session", periods: Period.summary)
    sessions.result = .success(.samples)

    return NavigationStack {
        List {
            HomeMetricSection(
                activities: activities,
                sessions: sessions,
                period: .today,
                path: .constant([])
            )
        }
        .listStyle(.plain)
    }
}
