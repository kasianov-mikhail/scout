//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct MetricSectionHeader: View {
    let title: String
    let trailing: String

    var body: some View {
        HStack {
            Text(verbatim: title.uppercased())
                .font(.system(size: 16, weight: .bold))

            Spacer()

            Text(verbatim: trailing)
                .font(.system(size: 13))
                .foregroundStyle(Color(.systemGray))
        }
        .padding(.top, 12)
        .frame(height: 56)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5)
        }
    }
}

struct MetricBucketRow: View {
    let row: MetricRow
    let label: String
    let format: MetricValueFormat
    let tone: MetricTone

    var body: some View {
        HStack(spacing: 8) {
            Text(verbatim: label)
                .font(.system(size: 13, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(Color(.systemGray))
                .frame(width: 56, alignment: .leading)

            HStack(spacing: 6) {
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.metricTrack)

                        if row.fraction > 0 {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.blue)
                                .frame(width: proxy.size.width * CGFloat(row.fraction))
                        }
                    }
                }
                .frame(height: 8)

                if row.isCurrent {
                    Text(verbatim: "so far")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.systemGray))
                        .frame(width: 34, alignment: .leading)
                }
            }

            Text(verbatim: row.value.map { format.label($0) } ?? "—")
                .font(.system(size: 14, design: .monospaced))
                .monospacedDigit()
                .frame(width: 56, alignment: .trailing)

            Text(verbatim: deltaLabel)
                .font(.system(size: 13))
                .foregroundStyle(row.isCurrent ? Color(.systemGray) : tone.color)
                .frame(width: 48, alignment: .trailing)
        }
        .frame(height: 40)
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
