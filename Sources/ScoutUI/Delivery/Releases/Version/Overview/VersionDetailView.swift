//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

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
        Group {
            switch provider.result {
            case nil:
                VersionDetailViewPlaceholder(version: release.id)
                    .transition(.opacity)
            case .success(let trend):
                content(trend: trend)
                    .transition(.opacity)
            case .failure(let error):
                ErrorView(description: Text(error.localizedDescription)) {
                    await provider.fetchAgain(in: database)
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.isLoading)
        .toolbarBackground(barSurface, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationTitle(en: "Release")
        .inlineNavigationTitle()
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
        .fetchTask([provider])
    }

    private func content(trend: VersionTrend) -> some View {
        let summary = VersionSummary(release: release, trend: trend)

        return List {
            VersionSummaryHeader(summary: summary)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

            VersionMetricGrid(
                summary: summary,
                showCrashes: { showAllCrashes = true },
                showHangs: { showAllHangs = true },
                showResources: { showAllResources = true }
            )
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)

            HangRateRow(summary: summary)
                .listRowInsets(.sideInsets)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }

    private var barSurface: Color {
        switch provider.result {
        case .success(let trend):
            VersionSummary(release: release, trend: trend).level.surface
        case .failure, nil:
            Color(.systemGray6)
        }
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

private struct HangRateRow: View {
    let summary: VersionSummary

    var body: some View {
        HStack(spacing: 8) {
            Text(verbatim: "Hang rate")
                .font(.system(size: 15))

            Spacer()

            Text(verbatim: summary.hangRateText)
                .font(.system(size: 13, design: .monospaced))
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(color)
        }
        .frame(minHeight: 44)
    }

    private var color: Color {
        guard let change = summary.hangRateChange else {
            return .primary
        }

        if change >= 0.1 {
            return .orange
        }

        if change <= -0.1 {
            return Stability.Level.healthy.accent
        }

        return .primary
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

#Preview("Loading") {
    NavigationStack {
        VersionDetailView(
            release: [ReleaseHealth].samples[0],
            provider: .init(version: "3.2.0")
        )
    }
    .environmentObject(Tint())
}
