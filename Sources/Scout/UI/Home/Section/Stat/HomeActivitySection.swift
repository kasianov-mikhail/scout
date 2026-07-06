//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeActivitySection: View {
    @Environment(\.database) var database
    @ObservedObject var activity: ActivityProvider

    var body: some View {
        ForEach(Array(ActivityPeriod.allCases.enumerated()), id: \.element) { index, period in
            ActivityRow(
                period: period,
                color: HomeSection.users.color,
                systemImage: HomeSection.users.systemImage,
                activity: activity
            )
            .listRowSeparator(index == 0 ? .hidden : .automatic, edges: .top)
        }
        .onAppear {
            Task { await activity.fetchIfNeeded(in: database) }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            HomeActivitySection(activity: .fixture())
        }
        .listStyle(.plain)
    }
}
