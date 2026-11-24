//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct AlertSensitivityCard: View {
    let watch: AlertDraft.Watch
    @Binding var sensitivity: AlertDraft.Sensitivity
    let countIsBelow: Bool

    var body: some View {
        AlertCard {
            HStack(spacing: 0) {
                ForEach(AlertDraft.Sensitivity.allCases.indices, id: \.self) { index in
                    let option = AlertDraft.Sensitivity.allCases[index]

                    Button {
                        sensitivity = option
                    } label: {
                        AlertSensitivityCell(
                            title: option.title,
                            detail: watch.detail(for: option, isBelow: countIsBelow),
                            isSelected: option == sensitivity
                        )
                    }
                    .buttonStyle(.solid)
                    .overlay(alignment: .trailing) {
                        if index < AlertDraft.Sensitivity.allCases.count - 1 {
                            Separator(axis: .vertical)
                        }
                    }
                }
            }
        }
    }
}

private struct AlertSensitivityCell: View {
    let title: String
    let detail: String
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: .space2) {
            Text(verbatim: title)
                .font(isSelected ? .scoutRowStrong : .scoutRow)
                .foregroundStyle(isSelected ? Color.fillAccent : Color.textPrimary)

            Text(verbatim: detail)
                .font(.scoutMicro)
                .foregroundStyle(isSelected ? Color.textLink.opacity(0.75) : Color.textMuted)
                .lineLimit(1)
        }
        .padding(.vertical, .space10)
        .padding(.horizontal, .space8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Color.surfaceSelected : Color.clear)
        .contentShape(Rectangle())
    }
}

struct AlertThresholdCard: View {
    let value: String
    let unit: String
    let decrement: () -> Void
    let increment: () -> Void

    var body: some View {
        AlertCard {
            HStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(verbatim: value)
                        .font(.scoutNumberS)
                        .monospacedDigit()

                    Text(verbatim: " \(unit)")
                        .font(.scoutCaption)
                        .foregroundStyle(Color.textMuted)
                }
                .padding(.vertical, .space10)
                .padding(.horizontal, .space8)
                .frame(maxWidth: .infinity, alignment: .leading)

                stepButton(symbol: "−", label: "Decrease", action: decrement)
                stepButton(symbol: "+", label: "Increase", action: increment)
            }
            .frame(height: 44)
        }
    }

    private func stepButton(symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(verbatim: symbol)
                .font(.scoutRowStrong)
                .foregroundStyle(Color.textLink)
                .frame(width: 48, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.solid)
        .overlay(alignment: .leading) {
            Separator(axis: .vertical)
        }
        .accessibilityLabel(Text(verbatim: label))
    }
}
