//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ReleaseView: View {
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
                ReleasePlaceholder(version: release.id)
                    .transition(.opacity)
            case .success(let trend):
                content(detail: ReleaseDetail(release: release, trend: trend, now: Date()))
                    .transition(.opacity)
            case .failure(let error):
                ErrorView(description: Text(error.localizedDescription)) {
                    await provider.fetchAgain(in: database)
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: provider.isLoading)
        .loadingInk(isLoading: provider.isLoading)
        .fetchTask([provider])
        .navigationTitle(en: "Release")
        .inlineNavigationTitle()
        .toolbarBackground(provider.isLoading ? Color(.systemGray6) : release.freeSessions.level.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
    }

    private var trend: VersionTrend {
        switch provider.result {
        case .success(let trend):
            trend
        case .failure, nil:
            .empty
        }
    }

    private func content(detail: ReleaseDetail) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ReleaseHero(detail: detail)
                    .padding(.horizontal, -16)

                ReleaseGrid(detail: detail) { kind in
                    switch kind {
                    case .crashes:
                        showAllCrashes = true
                    case .hangs:
                        showAllHangs = true
                    case .resources:
                        showAllResources = true
                    default:
                        break
                    }
                }
                .padding(.horizontal, -16)

                hangRate(detail.hangRate)
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
    }

    private func hangRate(_ value: ReleaseHangRate) -> some View {
        HStack(spacing: 8) {
            Text(verbatim: "Hang rate")
                .font(.weight450(size: 15))

            Spacer()

            HStack(spacing: 0) {
                Text(verbatim: value.value)

                if let change = value.change {
                    Text(verbatim: " · \(change)")
                }
            }
            .font(.system(size: 13, weight: .semibold, design: .monospaced))
            .foregroundStyle(value.color)
        }
        .frame(height: .rowRegular)
    }
}

private struct ReleaseGrid: View {
    let detail: ReleaseDetail
    let open: (ReleaseTileValue.Kind) -> Void

    var body: some View {
        let tiles = detail.tiles

        VStack(spacing: 0) {
            ForEach(0..<(tiles.count / 2), id: \.self) { index in
                HStack(spacing: 0) {
                    tile(tiles[index * 2], isLeading: true)
                    tile(tiles[index * 2 + 1], isLeading: false)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func tile(_ value: ReleaseTileValue, isLeading: Bool) -> some View {
        ReleaseTile(value: value, isLeading: isLeading, action: canOpen(value.kind) ? { open(value.kind) } : nil)
    }

    private func canOpen(_ kind: ReleaseTileValue.Kind) -> Bool {
        switch kind {
        case .crashes, .hangs, .resources: true
        case .crashFree, .adoption, .exits, .launchTime, .peakMemory: false
        }
    }
}

#Preview {
    NavigationStack {
        ReleaseView(
            release: [ReleaseHealth].samples[0],
            provider: .init(.success(.sample), version: "3.2.0")
        )
    }
    .environmentObject(Tint())
}

#Preview("Loading") {
    NavigationStack {
        ReleaseView(release: [ReleaseHealth].samples[0], provider: .init(version: "3.2.0"))
    }
    .environmentObject(Tint())
}
