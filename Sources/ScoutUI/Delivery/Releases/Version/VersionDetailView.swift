//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct VersionDetailView: View {
    let release: ReleaseHealth

    @Environment(\.database) private var database
    @StateObject var provider: VersionTrendProvider

    @State private var showAllCrashes = false
    @State private var showAllHangs = false
    @State private var showAllResources = false

    init(release: ReleaseHealth, provider: VersionTrendProvider? = nil) {
        self.release = release
        self._provider = StateObject(wrappedValue: provider ?? VersionTrendProvider(version: release.id))
    }

    var body: some View {
        InsetList {
            VStack(alignment: .leading, spacing: -8) {
                HStack(spacing: 24) {
                    Readout(title: "Crash-free sessions", stability: release.freeSessions)
                    if let freeUsers = release.freeUsers {
                        Readout(title: "Crash-free users", stability: freeUsers)
                    }
                }

                HStack(spacing: 24) {
                    Readout(title: "Crashes", value: "\(release.crashes)")
                    Readout(title: "Hangs", value: "\(release.hangs)")
                    Readout(title: "Sessions", value: release.sessions.compact)
                    Readout(title: "Adoption", value: release.adoption.formatted)
                }
            }
            .padding(.top)
            .padding(.bottom, 4)
            .listRowSeparator(.hidden, edges: .top)

            if let error = provider.error {
                ErrorRow(description: error.localizedDescription) {
                    await provider.fetchAgain(in: database)
                }
            }

            IncidentTrendSection(kind: .crash, days: trend.crashes) {
                if release.crashes > 0 {
                    AllButton { showAllCrashes = true }
                }
            }

            IncidentTrendSection(kind: .hang, days: trend.hangs) {
                if release.hangs > 0 {
                    AllButton { showAllHangs = true }
                }
            }

            ResourceSection(summary: release.resources, days: trend.resources) {
                showAllResources = true
            }

            ExitSection(summary: release.exits)
            PerformanceSection(release: release)
        }
        .navigationDestination(isPresented: $showAllCrashes) {
            VersionIncidentsView(
                issuesTitle: "Top crash issues",
                days: trend.crashes,
                provider: VersionIncidentProvider<Crash>(version: release.id)
            ) { group in
                CrashGroupDetailView(group: group)
            }
        }
        .navigationDestination(isPresented: $showAllHangs) {
            VersionIncidentsView(
                issuesTitle: "Top hang issues",
                days: trend.hangs,
                provider: VersionIncidentProvider<Hang>(version: release.id)
            ) { group in
                HangGroupDetailView(group: group)
            }
        }
        .navigationDestination(isPresented: $showAllResources) {
            VersionIncidentsView(
                issuesTitle: "Top resource issues",
                days: trend.resources,
                provider: VersionIncidentProvider<ResourceException>(version: release.id)
            ) { group in
                ResourceGroupDetailView(group: group)
            }
        }
        .toolbarBackground(release.freeSessions.color.opacity(0.12), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .monospacedNavigationTitle(en: release.id)
        .fetchTask([provider])
    }

    private var trend: VersionTrend {
        switch provider.result {
        case .success(let trend):
            trend
        case .failure, nil:
            .empty
        }
    }
}

#Preview {
    NavigationStack {
        VersionDetailView(
            release: [ReleaseHealth].samples[0],
            provider: .init(.success(.sample), version: "3.2.0")
        )
    }
    .environmentObject(Tint())
}

#Preview("Empty graph") {
    let release = [ReleaseHealth].samples[0]

    return NavigationStack {
        VersionDetailView(
            release: release,
            provider: .init(.success(.empty), version: release.id)
        )
    }
    .environmentObject(Tint())
}
