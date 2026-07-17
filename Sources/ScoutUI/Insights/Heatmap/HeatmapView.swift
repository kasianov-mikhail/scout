//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

struct HeatmapView: View {
    let grid: HeatmapGrid

    @Environment(\.chartColor) var color

    private let hours = 4

    var body: some View {
        let maxBlock = grid.maxBlockCount(hours: hours)

        Grid(horizontalSpacing: 4, verticalSpacing: 4) {
            GridRow {
                Color.clear
                    .gridCellUnsizedAxes([.horizontal, .vertical])
                ForEach(0..<24 / hours, id: \.self) { block in
                    Text(verbatim: "\(block * hours)–\(block * hours + hours)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            ForEach(0..<7) { day in
                GridRow {
                    Text(verbatim: HeatmapGrid.dayLabels[day])
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 30, alignment: .leading)
                    ForEach(0..<24 / hours, id: \.self) { block in
                        cell(day: day, block: block, maxBlock: maxBlock)
                    }
                }
            }
        }
    }

    private func cell(day: Int, block: Int, maxBlock: Int) -> some View {
        let count = grid.blockCount(day: day, block: block, hours: hours)
        let intensity = maxBlock > 0 ? Double(count) / Double(maxBlock) : 0
        return RoundedRectangle(cornerRadius: 6)
            .fill(count > 0 ? color.opacity(0.12 + 0.88 * intensity) : Color(.systemGray5))
            .frame(height: 32)
            .overlay {
                if count > 0 {
                    Text(verbatim: "\(count)")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(intensity > 0.55 ? Color.white : .secondary)
                }
            }
    }
}

#Preview("HeatmapView") {
    VStack(alignment: .leading, spacing: 24) {
        Text(verbatim: "With Data").font(.headline)
        HeatmapView(grid: .sample)

        Text(verbatim: "Empty State").font(.headline)
        HeatmapView(grid: HeatmapGrid(points: [], range: HeatmapGrid.recentRange(weeks: 4), calendar: .utc))
    }
    .padding()
}
