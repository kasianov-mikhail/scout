//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct MetricQuantileSelector: View {
    let summary: Percentiles?
    let previous: Percentiles?
    let telemetry: Telemetry.Export
    let format: MetricValueFormat

    @Binding var selection: MetricQuantile

    var body: some View {
        ReadoutTabStrip(
            values: MetricQuantile.allCases,
            isSelected: { $0 == selection },
            isLoading: false,
            spacing: .space12,
            onSelect: { selection = $0 },
            indicator: { _ in
                Rectangle()
                    .fill(Color.fillAccent)
                    .frame(height: .ruleThick)
            }
        ) { quantile, isActive in
            cell(quantile, isActive: isActive)
        }
    }

    private func cell(_ quantile: MetricQuantile, isActive: Bool) -> some View {
        let current = summary?.value(quantile)
        let delta = delta(current: current, previous: previous?.value(quantile))

        return VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: quantile.title)
                .font(.scoutCaptionStrong)
                .foregroundStyle(isActive ? Color.textPrimary : Color.textMuted)

            Text(verbatim: current.map { format.label($0) } ?? "—")
                .font(.scoutNumberL)
                .monospacedDigit()
                .foregroundStyle(isActive ? Color.textPrimary : Color.inactiveValue)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(verbatim: delta?.formatted ?? "—")
                .font(.scoutCaption)
                .foregroundStyle(tone(delta, quantile).color)
        }
        .padding(.top, .space10)
        .padding(.bottom, .space12)
        .contentShape(.rect)
    }

    private func delta(current: Double?, previous: Double?) -> Delta? {
        guard let current, let previous else {
            return nil
        }
        return Delta(current: current, previous: previous)
    }

    private func tone(_ delta: Delta?, _ quantile: MetricQuantile) -> MetricTone {
        guard telemetry == .timer, quantile == .p99, let delta, delta.value > 0.1 else {
            return .neutral
        }
        return .warning
    }
}
