//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricBucketRow: View {
    let row: MetricRow
    let label: String
    let format: MetricValueFormat
    let tone: MetricTone

    var body: some View {
        HStack(spacing: .space8) {
            Text(verbatim: label)
                .font(.scoutValue)
                .monospacedDigit()
                .foregroundStyle(Color.textMuted)
                .frame(width: 56, alignment: .leading)

            HStack(spacing: .space6) {
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: .radiusBar)
                            .fill(Color.metricTrack)

                        if row.fraction > 0 {
                            RoundedRectangle(cornerRadius: .radiusBar)
                                .fill(Color.fillAccent)
                                .frame(width: proxy.size.width * CGFloat(row.fraction))
                        }
                    }
                }
                .frame(height: 8)

                if row.isCurrent {
                    Text(verbatim: "so far")
                        .font(.scoutFootnote)
                        .foregroundStyle(Color.textMuted)
                        .frame(width: 34, alignment: .leading)
                }
            }

            Text(verbatim: row.value.map { format.label($0) } ?? "—")
                .font(.scoutValue)
                .monospacedDigit()
                .frame(width: 56, alignment: .trailing)

            Text(verbatim: deltaLabel)
                .font(.scoutCaption)
                .foregroundStyle(row.isCurrent ? Color.fillLevel : tone.color)
                .frame(width: 48, alignment: .trailing)
        }
        .frame(height: .rowTable)
        .overlay(alignment: .bottom) {
            if !row.isOldest {
                DashedLine()
            }
        }
    }

    private var deltaLabel: String {
        if row.isCurrent {
            return ""
        }
        return row.delta?.formatted ?? "—"
    }
}
