//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct TrendCard: View {
    let title: String
    let color: Color
    let trend: Trend?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: title.uppercased())
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.leading, 1)

            HStack(alignment: .top) {
                ZStack(alignment: .leading) {
                    Text(verbatim: "0").hidden()

                    if let count = trend?.count {
                        Text(count == 0 ? "—" : count.compact)
                    } else if trend != nil {
                        Redacted(length: 5).font(.body)
                    } else {
                        Text(verbatim: "0")
                    }
                }
                .font(.system(size: 24, weight: .bold, design: .rounded))

                Spacer()

                if let delta = trend?.delta {
                    Text(verbatim: delta.formatted)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(delta.isPositive ? .green : .red)
                        .padding(.top, 2)
                }
            }

            Spacer().frame(height: 4)

            Group {
                if let series = trend?.series {
                    Sparkline(series: series, color: color)
                } else {
                    Sparkline(series: .empty, color: color)
                }
            }
            .frame(height: 68)
        }
    }
}

#Preview("TrendCard") {
    let columns = [GridItem(.fixed(162), spacing: 24), GridItem(.fixed(162), spacing: 24)]

    LazyVGrid(columns: columns, spacing: 24) {
        TrendCard(
            title: "Sessions",
            color: .purple,
            trend: Trend(count: 8420, previous: 7500, values: [3, 5, 4, 7, 6, 9, 12])
        )
        TrendCard(
            title: "Crashes",
            color: .red,
            trend: Trend(count: 87, previous: 101, values: [9, 7, 8, 6, 7, 5, 4])
        )
        TrendCard(
            title: "Empty",
            color: .red,
            trend: Trend(count: 0, previous: 0, values: [0, 0, 0, 0, 0, 0, 0])
        )
        TrendCard(
            title: "Loading",
            color: .green,
            trend: .loading
        )
        TrendCard(
            title: "Missing",
            color: .green,
            trend: nil
        )
    }
    .padding()
}
