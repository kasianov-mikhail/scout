//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

enum NetworkLedgerLabel {
    case hour
    case weekday
    case monthDay
    case month

    var formatter: DateFormatter {
        switch self {
        case .hour:
            .networkHourLabel
        case .weekday:
            .networkDayLabel
        case .monthDay:
            .networkMonthDayLabel
        case .month:
            .networkMonthLabel
        }
    }
}

struct NetworkLedgerRowView: View {
    let row: NetworkLedgerRow
    let maxRequests: Int
    let label: NetworkLedgerLabel
    let component: Calendar.Component
    let showsDivider: Bool

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: label.formatter.string(from: row.date))
                    .font(.weighted(size: 13, weight: row.isCurrent ? .semibold : .regular, design: .monospaced))
                    .lineLimit(1)

                if component == .day && row.isCurrent {
                    Text(verbatim: "today")
                        .font(.weight450(size: 11))
                        .foregroundStyle(Color(.systemGray))
                }
            }
            .frame(width: 58, alignment: .leading)

            BarValue(text: row.requests.compact, fraction: fraction, color: .networkTrack, barHeight: 28, minimumWidth: 4)
                .frame(maxWidth: .infinity)
                .frame(height: 18)

            Text(verbatim: row.successRate.networkValue)
                .foregroundStyle(row.successRate.networkColor)
                .frame(width: 56, alignment: .trailing)

            Text(verbatim: row.p99.networkP99Value)
                .font(.weighted(size: 13, weight: row.p99.networkP99Weight, design: .monospaced))
                .foregroundStyle(row.p99.networkP99Color)
                .frame(width: 64, alignment: .trailing)
        }
        .font(.weight450(size: 13, design: .monospaced))
        .frame(minHeight: 40)
        .padding(.vertical, 6)
        .overlay(alignment: .bottom) {
            if showsDivider {
                DashedLine()
            }
        }
        .contentShape(.rect)
    }

    private var fraction: Double {
        maxRequests > 0 ? Double(row.requests) / Double(maxRequests) : 0
    }
}
