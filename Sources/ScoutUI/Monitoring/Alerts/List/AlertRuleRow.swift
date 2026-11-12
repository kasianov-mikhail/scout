//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct AlertRuleRow: View {
    let status: AlertStatus
    let isLast: Bool
    let onDelete: () -> Void
    let onMute: () -> Void
    let onOpen: () -> Void

    var body: some View {
        AlertSwipeRow(
            content: { content },
            onDelete: { onDelete() },
            onMute: status.isMuted ? nil : onMute,
            onOpen: onOpen
        )
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(verbatim: status.rule.metric.title)
                    .font(titleFont)
                    .foregroundStyle(.primary)

                Spacer(minLength: 0)

                if let label = status.firingLabel() {
                    Text(verbatim: label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(.systemRed))
                        .fixedSize()
                } else if let label = status.mutedLabel {
                    Text(verbatim: label)
                        .font(.book(size: 13))
                        .foregroundStyle(Color(.systemGray))
                        .fixedSize()
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(verbatim: status.summary)
                    .font(.book(size: 13))
                    .foregroundStyle(Color(.systemGray))

                Spacer(minLength: 0)

                if let value = status.value {
                    Text(verbatim: value)
                        .font(.book(size: 14, design: .monospaced))
                        .monospacedDigit()
                        .foregroundStyle(status.isFiring ? Color(.systemRed) : .primary)
                        .fixedSize()
                }
            }

            AlertHealthStrip(buckets: status.buckets)
                .padding(.top, 4)
        }
        .padding(.top, 12)
        .padding(.bottom, 14)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle()
                    .fill(Color.separator)
                    .frame(height: 0.5)
                    .padding(.horizontal, 16)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var titleFont: Font {
        switch status.rule.metric {
        case .eventCount:
            .book(size: 15, design: .monospaced)
        case .crashFreeSessions:
            .system(size: 16, weight: .semibold)
        }
    }
}

#Preview("Alert rows") {
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(Array(AlertStatus.armedSamples.enumerated()), id: \.element.rule) { index, status in
                AlertRuleRow(
                    status: status,
                    isLast: index == AlertStatus.armedSamples.count - 1,
                    onDelete: {},
                    onMute: {},
                    onOpen: {}
                )
                .padding(.horizontal, -16)
            }

            AlertRuleRow(status: .firingSample, isLast: false, onDelete: {}, onMute: {}, onOpen: {})
                .padding(.horizontal, -16)

            AlertRuleRow(status: .mutedSample, isLast: true, onDelete: {}, onMute: {}, onOpen: {})
                .padding(.horizontal, -16)
        }
        .padding(.horizontal, 16)
    }
    .scrollIndicators(.hidden)
}
