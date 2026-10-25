//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

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
                    title: period.activityPeriod.rawValue,
                    color: .green,
                    trend: activityTrend,
                    risesAreBad: false
                )
            }
            .buttonStyle(.plain)

            Button {
                path.append(.sessions)
            } label: {
                TrendCard(
                    title: "Sessions",
                    color: .purple,
                    trend: sessionTrend,
                    risesAreBad: false
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 24)
        .listRowSeparator(.hidden, edges: .bottom)
    }

    private var activityTrend: Trend {
        switch activities.result {
        case .success(let points):
            Trend(latest: points, period: period)
        case .failure, nil:
            .loading
        }
    }

    private var sessionTrend: Trend {
        switch sessions.result {
        case .success(let points):
            Trend(total: points, period: period)
        case .failure, nil:
            .loading
        }
    }
}

#Preview {
    NavigationStack {
        InsetList {
            HomeMetricSection(
                activities: .init(.success(.samples)),
                sessions: .init(.success(.samples), subject: .sessions),
                period: .today,
                path: .constant([])
            )
        }
    }
}
