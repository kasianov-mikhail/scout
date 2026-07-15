//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricCard: View {
    let title: String
    let image: String
    let color: Color
    let summary: MetricSummary?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: image)
                    .foregroundColor(color)
                Spacer()
                Text(verbatim: title.uppercased())
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }

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
}

#Preview("MetricCard") {
    HStack(spacing: 24) {
        MetricCard(
            title: "Sessions",
            image: "clock",
            color: .purple,
            summary: MetricSummary(count: 8420, previous: 7500, values: [3, 5, 4, 7, 6, 9, 12])
        )
        MetricCard(
            title: "Crashes",
            image: "exclamationmark.triangle",
            color: .red,
            summary: MetricSummary(count: 87, previous: 101, values: [9, 7, 8, 6, 7, 5, 4])
        )
    }
    .padding()
}

#Preview("MetricCard — states") {
    VStack(spacing: 24) {
        MetricCard(title: "Empty", image: "clock", color: .red, summary: MetricSummary(count: 0, previous: 0, values: [0, 0, 0, 0, 0, 0, 0]))
        MetricCard(title: "Loading", image: "clock", color: .green, summary: .loading)
        MetricCard(title: "Missing", image: "clock", color: .green, summary: nil)
    }
    .padding()
}
