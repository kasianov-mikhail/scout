//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct HomeList: View {
    @AppStorage("scout_home_section") var section = HomeSection.sessions

    @StateObject var activities = ActivityProvider()
    @StateObject var sessions = StatProvider(eventName: "Session", periods: Period.summary)
    @StateObject var crashes = StatProvider(eventName: "Crash", periods: Period.summary)
    @StateObject var releases = ReleaseHealthProvider()
    @StateObject var logs = HomeLogProvider()

    @State var showReleaseHealth = false

    var body: some View {
        if let error = HomeErrorView(providers: [sessions, crashes, activities, logs, releases]) {
            error
        } else {
            List {
                SegmentStrip(selection: $section, tint: \.color, title: \.title)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    .listRowSeparator(.hidden)

                switch section {
                case .sessions:
                    HomeStatSection(section: .sessions, stat: sessions)
                case .crashes:
                    HomeStatSection(section: .crashes, stat: crashes)
                case .users:
                    HomeActivitySection(activity: activities)
                }

                HomeLogSection(provider: logs)
                HomeReleaseSection(provider: releases, showReleaseHealth: $showReleaseHealth)
            }
            .navigationDestination(isPresented: $showReleaseHealth) {
                ReleaseHealthView(provider: releases)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    NavigationStack {
        HomeList(
            activities: .fixture(),
            sessions: .fixture(eventName: "Session"),
            crashes: .fixture(eventName: "Crash"),
            releases: .fixture(),
            logs: .fixture()
        )
        .navigationTitle(en: "Home")
    }
    .environmentObject(Tint())
}
