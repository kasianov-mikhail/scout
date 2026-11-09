//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct MetricSummaryView: View {
    let summary: MetricSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(verbatim: summary.value)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .monospacedDigit()

                Text(verbatim: summary.unit)
                    .font(.weight450(size: 15))
                    .foregroundStyle(Color(.systemGray))
                    .lineLimit(1)
            }

            if let detail = summary.detail {
                Text(verbatim: detail)
                    .font(.weight450(size: 13))
                    .foregroundStyle(summary.tone.color)
            }
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension MetricTone {
    var color: Color {
        switch self {
        case .positive:
            .trendPositive
        case .neutral:
            Color(.systemGray)
        case .warning:
            .hangText
        }
    }
}

#Preview("Summary") {
    InsetList {
        MetricSummaryView(
            summary: MetricSummary(
                total: 1_284,
                previous: 1_189,
                range: .today,
                format: .counter
            )
        )
        .frame(minHeight: 44)
    }
}
