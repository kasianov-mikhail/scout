//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricCard: View {
    let summary: MetricSummary?
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                let font = Font.system(size: 24, weight: .bold, design: .rounded)

                if let summary {
                    RedactedText(count: summary.count).font(font)
                } else {
                    Text(verbatim: "—").font(font)
                }

                Spacer()

                if let delta = summary?.delta {
                    Text(verbatim: delta.formatted)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(delta.isPositive ? .green : .red)
                        .padding(.top, 2)
                }
            }

            if let series = summary?.series {
                Sparkline(series: series, color: color)
            } else if summary != nil {
                Sparkline(series: .placeholder, color: Color(.systemGray3)).redacted(reason: .placeholder)
            } else {
                Sparkline(series: .empty, color: color)
            }
        }
    }
}

#Preview("MetricCard") {
    VStack(spacing: 24) {
        let summary = MetricSummary(count: 8420, previous: 7500, values: [3, 5, 4, 7, 6, 9, 12])

        MetricCard(summary: summary, color: .purple)
            .frame(width: 162, height: 100)

        MetricCard(summary: MetricSummary(count: 0, previous: 0, values: [0, 0, 0, 0, 0, 0, 0]), color: .red)
            .frame(width: 162, height: 100)

        MetricCard(summary: .loading, color: .green)
            .frame(width: 162, height: 100)

        MetricCard(summary: nil, color: .green)
            .frame(width: 162, height: 100)
    }
    .padding()
}
