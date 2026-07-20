//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct MetricCard: View {
    let title: String
    let color: Color
    let summary: MetricSummary?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: title.uppercased())
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .padding(.leading, 1)

            HStack(alignment: .top) {
                ZStack(alignment: .leading) {
                    Text(verbatim: "0").hidden()

                    if let count = summary?.count {
                        Text(count == 0 ? "—" : count.compact)
                    } else if summary != nil {
                        Redacted(length: 5).font(.body)
                    } else {
                        Text(verbatim: "0")
                    }
                }
                .font(.system(size: 24, weight: .bold, design: .rounded))

                Spacer()

                if let delta = summary?.delta {
                    Text(verbatim: delta.formatted)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(delta.isPositive ? .green : .red)
                        .padding(.top, 2)
                }
            }

            Spacer().frame(height: 4)

            Group {
                if let series = summary?.series {
                    Sparkline(series: series, color: color)
                } else {
                    Sparkline(series: .empty, color: color)
                }
            }
            .frame(height: 68)
        }
    }
}

#Preview("MetricCard") {
    let columns = [GridItem(.fixed(162), spacing: 24), GridItem(.fixed(162), spacing: 24)]

    LazyVGrid(columns: columns, spacing: 24) {
        MetricCard(
            title: "Sessions",
            color: .purple,
            summary: MetricSummary(count: 8420, previous: 7500, values: [3, 5, 4, 7, 6, 9, 12])
        )
        MetricCard(
            title: "Crashes",
            color: .red,
            summary: MetricSummary(count: 87, previous: 101, values: [9, 7, 8, 6, 7, 5, 4])
        )
        MetricCard(
            title: "Empty",
            color: .red,
            summary: MetricSummary(count: 0, previous: 0, values: [0, 0, 0, 0, 0, 0, 0])
        )
        MetricCard(
            title: "Loading",
            color: .green,
            summary: .loading
        )
        MetricCard(
            title: "Missing",
            color: .green,
            summary: nil
        )
    }
    .padding()
}
