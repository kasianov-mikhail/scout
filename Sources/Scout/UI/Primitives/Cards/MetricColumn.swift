//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricColumn: View {
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
            MetricCard(summary: summary, color: color)
        }
    }
}

#Preview {
    HStack(spacing: 24) {
        MetricColumn(
            title: "Sessions",
            image: "clock",
            color: .purple,
            summary: MetricSummary(count: 8420, previous: 7500, values: [3, 5, 4, 7, 6, 9, 12])
        )
        MetricColumn(
            title: "Crashes",
            image: "exclamationmark.triangle",
            color: .red,
            summary: MetricSummary(count: 87, previous: 101, values: [9, 7, 8, 6, 7, 5, 4])
        )
    }
    .padding()
}
