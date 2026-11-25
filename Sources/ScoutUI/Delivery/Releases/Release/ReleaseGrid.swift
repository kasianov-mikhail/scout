//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct ReleaseGrid: View {
    let detail: ReleaseDetail

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
        .padding(.horizontal, .gutter)
    }

    @ViewBuilder
    private func tile(_ value: ReleaseTileValue, isLeading: Bool) -> some View {
        let label = ReleaseTile(value: value, isLeading: isLeading, action: nil)

        switch value.kind {
        case .crashes:
            NavigationLink {
                VersionIncidentsView(
                    issuesTitle: "Top crash issues",
                    days: detail.trend.crashes,
                    provider: VersionIncidentProvider<Crash>(version: detail.release.id)
                ) { group in
                    CrashGroupDetailView(group: group)
                }
            } label: {
                label
            }
            .buttonStyle(.solid)
        case .hangs:
            NavigationLink {
                VersionIncidentsView(
                    issuesTitle: "Top hang issues",
                    days: detail.trend.hangs,
                    provider: VersionIncidentProvider<Hang>(version: detail.release.id)
                ) { group in
                    HangGroupDetailView(group: group)
                }
            } label: {
                label
            }
            .buttonStyle(.solid)
        case .resources:
            NavigationLink {
                VersionIncidentsView(
                    issuesTitle: "Top resource issues",
                    days: detail.trend.resources,
                    provider: VersionIncidentProvider<ResourceException>(version: detail.release.id)
                ) { group in
                    ResourceGroupDetailView(group: group)
                }
            } label: {
                label
            }
            .buttonStyle(.solid)
        case .crashFree, .adoption, .exits, .launchTime, .peakMemory:
            label
        }
    }
}
