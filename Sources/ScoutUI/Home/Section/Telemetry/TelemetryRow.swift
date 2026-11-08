//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct TelemetryRow: View {
    enum Side {
        case leading
        case trailing
    }

    let item: TelemetryItem
    let side: Side
    let showsDivider: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: item.kind.systemImage)
                    .font(.weight450(size: 18))
                    .foregroundStyle(item.kind.color)
                    .frame(width: 24)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(verbatim: item.kind.title)
                            .font(.telemetryTitle)

                        Spacer(minLength: 0)

                        Text(verbatim: item.valueLabel)
                            .font(.body.weight(.semibold))
                            .monospacedDigit()
                    }

                    Text(verbatim: item.caption)
                        .font(.telemetryCaption)
                        .foregroundStyle(Color(.systemGray))
                }
            }
            .padding(.leading, side == .trailing ? 12 : 0)
            .padding(.trailing, side == .leading ? 12 : 0)
            .frame(height: 66)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .overlay(alignment: .bottom) {
                if showsDivider {
                    Rectangle()
                        .fill(Color.separator)
                        .frame(height: 0.5)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        InsetList {
            TelemetryRow(item: TelemetryItem.sample[0], side: .leading, showsDivider: true) {}
            TelemetryRow(item: TelemetryItem.sample[1], side: .trailing, showsDivider: false) {}
        }
    }
}
