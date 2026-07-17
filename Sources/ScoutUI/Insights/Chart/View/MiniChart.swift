//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import ScoutCore
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
                Sparkline(series: series, color: color, lineWidth: 1.5, showsGridlines: false)
            } else {
                Sparkline(series: .placeholder, color: Color(.systemGray3), lineWidth: 1.5, showsGridlines: false)
                    .redacted(reason: .placeholder)
            }
        }
        .frame(width: Self.size.width, height: Self.size.height)
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
                MiniChart(
                    series: MiniChartSeries(values: Array(repeating: 0, count: MiniChartSeries.sliceCount)), color: .red
                )
            }
        }
        .listStyle(.plain)
    }
}
