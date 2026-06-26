//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Charts
import SwiftUI

/// An inline sparkline for Home rows: the period's slice values drawn as a
/// smooth line over a gradient fill fading to the baseline.
///
/// While the series is loading, a redacted placeholder of the same size
/// keeps rows stable.
///
struct MiniChart: View {
    /// Pinned size so charts and placeholders align across Home rows.
    static let size = CGSize(width: 56, height: 22)

    let series: MiniChartSeries?
    let color: Color

    var body: some View {
        Group {
            if let series {
                chart(for: series, tint: color)
            } else {
                chart(for: .placeholder, tint: Color(.systemGray3))
                    .redacted(reason: .placeholder)
            }
        }
        .frame(width: Self.size.width, height: Self.size.height)
    }

    private func chart(for series: MiniChartSeries, tint: Color) -> some View {
        Chart(series.values.indices, id: \.self) { index in
            AreaMark(x: .value("X", index), y: .value("Y", series.values[index]))
                .interpolationMethod(.catmullRom)
                .foregroundStyle(gradient(of: tint))
            LineMark(x: .value("X", index), y: .value("Y", series.values[index]))
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 1.5))
                .foregroundStyle(tint)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }

    private func gradient(of tint: Color) -> LinearGradient {
        LinearGradient(
            colors: [tint.opacity(0.35), tint.opacity(0.02)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    NavigationStack {
        List {
            HStack {
                Text(verbatim: "Loaded")
                Spacer()
                MiniChart(series: MiniChartSeries(values: [2, 4, 3, 7, 6, 11, 16]), color: .red)
            }
            HStack {
                Text(verbatim: "Loading")
                Spacer()
                MiniChart(series: nil, color: .red)
            }
            HStack {
                Text(verbatim: "Empty")
                Spacer()
                MiniChart(series: MiniChartSeries(values: Array(repeating: 0, count: MiniChartSeries.sliceCount)), color: .red)
            }
        }
        .listStyle(.plain)
    }
}
