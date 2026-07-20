//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AlertRow: View {
    let status: AlertStatus

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(status.outcome.state.color)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: status.rule.metric.title)
                    .font(.subheadline.weight(.medium))

                if let detail = status.detail {
                    Text(verbatim: detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
            MiniChart(series: status.series, color: status.outcome.state.color)
        }
        .frame(height: 68)
        .listRowInsets(.sideInsets)
    }
}

struct AlertRowPlaceholder: View {
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.gray)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "Crash-free sessions")
                    .font(.body.weight(.medium))
                Text(verbatim: "99.50% — below 99.50%")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            MiniChart(series: nil, color: .gray)
        }
        .padding(.vertical, 4)
        .redacted(reason: .placeholder)
        .trailingRowSeparator()
    }
}

extension AlertState {
    var color: Color {
        switch self {
        case .armed:
            .green
        case .firing:
            .red
        case .muted:
            .gray
        }
    }

    var icon: String {
        switch self {
        case .armed:
            "checkmark.circle.fill"
        case .firing:
            "exclamationmark.triangle.fill"
        case .muted:
            "bell.slash.fill"
        }
    }
}
