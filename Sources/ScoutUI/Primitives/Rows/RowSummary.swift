//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct RowSummary: View {
    static let countWidth: CGFloat = 80

    let series: MiniChartSeries?
    let count: Int?
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            MiniChart(series: series, color: color)
            RedactedText(count: count)
                .foregroundColor(color)
                .frame(minWidth: Self.countWidth, alignment: .trailing)
        }
    }
}

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
                RowSummary(
                    series: MiniChartSeries(values: Array(repeating: 0, count: MiniChartSeries.sliceCount)), count: 0,
                    color: .blue)
            }
        }
        .listStyle(.plain)
    }
}
