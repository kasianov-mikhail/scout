//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI

struct AlertNowCard: View {
    let status: AlertStatus?
    let metric: AlertMetric

    var body: some View {
        AlertCard {
            VStack(spacing: 0) {
                value
                    .overlay(alignment: .bottom) {
                        Separator()
                    }
                stats
            }
        }
        .animation(.easeOut(duration: 0.2), value: status)
    }

    private var value: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            if let text = valueText {
                Text(verbatim: text)
                    .font(.scoutNumberS)
                    .foregroundStyle(status?.isFiring == true ? Color.fillDanger : Color.textPrimary)
                    .monospacedDigit()
            } else {
                SkeletonBar(width: 74, height: 16, delay: 0)
                    .matchingLineHeight(.scoutNumberS)
            }

            if status == nil {
                SkeletonBar(width: 74, height: 8, delay: 0)
                    .frame(height: 16, alignment: .leading)
                    .padding(.leading, .space4)
            } else {
                Text(verbatim: " \(unit)")
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)
            }
        }
        .padding(.vertical, .space10)
        .padding(.horizontal, .space8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stats: some View {
        HStack(spacing: 0) {
            stat(
                title: "Alerting since",
                text: alertingSince,
                color: status?.isFiring == true ? Color.fillDanger : Color.textPrimary,
                showsDivider: true
            )
            stat(title: "Notified", text: notified, color: Color.textPrimary, showsDivider: false)
        }
    }

    private func stat(title: String, text: String?, color: Color, showsDivider: Bool) -> some View {
        VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: title)
                .font(.scoutMicro)
                .foregroundStyle(Color.textMuted)

            if let text {
                Text(verbatim: text)
                    .font(.scoutRowStrong)
                    .foregroundStyle(color)
            } else {
                SkeletonBar(width: 46, height: 11, delay: 0)
                    .matchingLineHeight(.scoutRowStrong)
            }
        }
        .padding(.vertical, .space8)
        .padding(.horizontal, .space8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .trailing) {
            if showsDivider {
                Separator(axis: .vertical)
            }
        }
    }

    private var valueText: String? {
        guard let status else {
            return nil
        }
        guard let value = status.reading.recent.last else {
            return "—"
        }
        return status.rule.metric.format(value)
    }

    private var unit: String {
        switch metric {
        case .crashFreeSessions:
            "crash-free sessions"
        case .eventCount:
            "events an hour"
        }
    }

    private var alertingSince: String? {
        guard let status else {
            return nil
        }
        guard let start = status.firingStart else {
            return "—"
        }
        return alertTimeFormatter.string(from: start)
    }

    private var notified: String? {
        guard let status else {
            return nil
        }
        guard let date = status.notified else {
            return "—"
        }
        return alertTimeFormatter.string(from: date)
    }
}

private let alertTimeFormatter = DateFormatter(format: "HH:mm")
