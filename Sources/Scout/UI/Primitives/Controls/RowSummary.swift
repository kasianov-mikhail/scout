//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

/// The trailing summary of a Home row: a mini-chart next to the period's
/// count, both tinted with the row's color.
///
/// The chart's fixed size and the count's minimum width stack the
/// summaries into aligned columns.
///
struct RowSummary: View {
    /// Minimum count width: rows whose counts fit it get their charts and
    /// counts stacked into aligned columns; wider counts push their chart left.
    static let countWidth: CGFloat = 56

    let series: MiniChartSeries?
    let count: Int?
    let color: Color

    var body: some View {
        HStack(spacing: 32) {
            MiniChart(series: series, color: color)
            RedactedText(count: count)
                .foregroundColor(color)
                .frame(minWidth: Self.countWidth, alignment: .trailing)
        }
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        List {
            HStack {
                Text(verbatim: "Loaded")
                Spacer()
                RowSummary(series: MiniChartSeries(values: [2, 4, 3, 7, 6, 11, 16]), count: 49, color: .red)
            }
            HStack {
                Text(verbatim: "Wide count")
                Spacer()
                RowSummary(series: MiniChartSeries(values: [3, 1, 4, 1, 5, 9, 2]), count: 19_989, color: .green)
            }
            HStack {
                Text(verbatim: "Loading")
                Spacer()
                RowSummary(series: nil, count: nil, color: .purple)
            }
            HStack {
                Text(verbatim: "Empty")
                Spacer()
                RowSummary(series: MiniChartSeries(values: Array(repeating: 0, count: MiniChartSeries.sliceCount)), count: 0, color: .blue)
            }
        }
        .listStyle(.plain)
    }
}
