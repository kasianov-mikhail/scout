//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
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
                TrendCard(
                    title: "Users",
                    color: .green,
                    trend: activityTrend
                )
            }
            .buttonStyle(.plain)

            Button {
                path.append(.sessions)
            } label: {
                TrendCard(
                    title: "Sessions",
                    color: .purple,
                    trend: sessionTrend
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 24)
        .listRowSeparator(.hidden, edges: .bottom)
    }

    private var activityTrend: Trend? {
        guard let activityPeriod = period.activityPeriod else {
            return nil
        }
        guard let points = try? activities.result?.get() else {
            return .loading
        }
        return Trend(levels: points.points(on: activityPeriod), period: period)
    }

    private var sessionTrend: Trend {
        guard let points = try? sessions.result?.get() else {
            return .loading
        }
        return Trend(points: points, period: period)
    }
}

#Preview {
    let activities = ActivityProvider()
    activities.result = .success(.samples)

    let sessions = StatProvider(eventName: "Session", periods: Period.summary)
    sessions.result = .success(.samples)

    return NavigationStack {
        InsetList {
            HomeMetricSection(
                activities: activities,
                sessions: sessions,
                period: .today,
                path: .constant([])
            )
        }
    }
}
