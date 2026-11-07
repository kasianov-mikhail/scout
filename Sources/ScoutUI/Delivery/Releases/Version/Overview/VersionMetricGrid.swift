//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct VersionMetricGrid: View {
    let summary: VersionSummary
    let showCrashes: () -> Void
    let showHangs: () -> Void
    let showResources: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(stride(from: 0, to: tiles.count, by: 2)), id: \.self) { index in
                HStack(alignment: .top, spacing: 0) {
                    tileView(tile: tiles[index], leading: true)

                    if index + 1 < tiles.count {
                        tileView(tile: tiles[index + 1], leading: false)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func tileView(tile: Tile, leading: Bool) -> some View {
        VersionMetricTile(
            metric: tile.metric,
            value: tile.value,
            color: tile.color,
            footnote: tile.footnote,
            chart: tile.chart,
            leading: leading,
            action: tile.action
        )
    }

    private var tiles: [Tile] {
        let release = summary.release

        return [
            Tile(
                metric: .stability,
                value: release.freeSessions.formatted,
                color: .primary,
                footnote: summary.freeUsersNote,
                chart: .stability(release.freeSessions),
                action: nil
            ),
            Tile(
                metric: .adoption,
                value: release.adoption.formatted,
                color: .primary,
                footnote: summary.sessionsNote,
                chart: .adoption(release.adoption),
                action: nil
            ),
            Tile(
                metric: .crashes,
                value: "\(release.crashes)",
                color: .crashValue,
                footnote: "\(summary.crashesToday) today",
                chart: .bars(summary.crashes, color: .red),
                action: showCrashes
            ),
            Tile(
                metric: .hangs,
                value: "\(release.hangs)",
                color: .hangValue,
                footnote: "\(summary.hangsToday) today",
                chart: .bars(summary.hangs, color: .orange),
                action: showHangs
            ),
            Tile(
                metric: .resources,
                value: "\(release.resources.total)",
                color: .resourceValue,
                footnote: summary.resourcesNote,
                chart: .bars(summary.resources, color: .indigo),
                action: showResources
            ),
            Tile(
                metric: .exits,
                value: summary.exitsPerMille,
                color: .primary,
                footnote: summary.topExitNote,
                chart: .exits(summary.exitShares),
                action: nil
            ),
            Tile(
                metric: .launch,
                value: summary.launchValue,
                color: .primary,
                footnote: summary.launchNote,
                chart: .bars(summary.launchBars, color: nil),
                action: nil
            ),
            Tile(
                metric: .memory,
                value: summary.peakMemoryValue,
                color: .primary,
                footnote: summary.peakMemoryNote,
                chart: .bars(summary.peakMemoryBars, color: nil),
                action: nil
            ),
        ]
    }

    private struct Tile {
        let metric: VersionMetric
        let value: String
        let color: Color
        let footnote: String
        let chart: VersionMetricChart
        let action: (() -> Void)?
    }
}
