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
        HStack(spacing: 12) {
            ForEach(MetricQuantile.allCases) { quantile in
                Button {
                    selection = quantile
                } label: {
                    cell(quantile)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(quantile == selection ? .isSelected : [])
            }
        }
        .background(alignment: .bottom) {
            Separator()
        }
    }

    private func cell(_ quantile: MetricQuantile) -> some View {
        let isSelected = quantile == selection
        let current = summary?.value(quantile)
        let delta = delta(current: current, previous: previous?.value(quantile))

        return VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: quantile.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? Color.primary : Color(.systemGray))

            Text(verbatim: current.map { format.label($0) } ?? "—")
                .font(.system(size: 28, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(isSelected ? Color.primary : Color.inactiveValue)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(verbatim: delta?.formatted ?? "—")
                .font(.book(size: 13))
                .foregroundStyle(tone(delta, quantile).color)
        }
        .padding(.top, 10)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            if isSelected {
                Rectangle()
                    .fill(Color.blue)
                    .frame(height: 2)
            }
        }
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
