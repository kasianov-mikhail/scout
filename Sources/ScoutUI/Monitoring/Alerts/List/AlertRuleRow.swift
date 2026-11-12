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
        VStack(alignment: .leading, spacing: .space6) {
            HStack(alignment: .firstTextBaseline, spacing: .space12) {
                Text(verbatim: status.rule.metric.title)
                    .font(titleFont)
                    .foregroundStyle(Color.textPrimary)

                Spacer(minLength: 0)

                if let label = status.firingLabel() {
                    Text(verbatim: label)
                        .font(.scoutCaptionStrong)
                        .foregroundStyle(Color.textDanger)
                        .fixedSize()
                } else if let label = status.mutedLabel {
                    Text(verbatim: label)
                        .font(.scoutCaption)
                        .foregroundStyle(Color.textMuted)
                        .fixedSize()
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: .space12) {
                Text(verbatim: status.summary)
                    .font(.scoutCaption)
                    .foregroundStyle(Color.textMuted)

                Spacer(minLength: 0)

                if let value = status.value {
                    Text(verbatim: value)
                        .font(.scoutValue)
                        .monospacedDigit()
                        .foregroundStyle(status.isFiring ? Color.textDanger : .primary)
                        .fixedSize()
                }
            }

            AlertHealthStrip(buckets: status.buckets)
                .padding(.top, .space4)
        }
        .padding(.top, .space12)
        .padding(.bottom, .space12)
        .padding(.horizontal, .gutter)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle()
                    .fill(Color.separator)
                    .frame(height: 0.5)
                    .padding(.horizontal, .gutter)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var titleFont: Font {
        switch status.rule.metric {
        case .eventCount:
            .scoutRowMono
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
        .padding(.horizontal, .gutter)
    }
    .scrollIndicators(.hidden)
}
