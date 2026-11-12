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
    let showsValues: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: item.kind.systemImage)
                    .font(.book(size: 18))
                    .foregroundStyle(item.kind.color)
                    .frame(width: 24)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    if showsValues {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            title

                            Spacer(minLength: 0)

                            Text(verbatim: item.valueLabel)
                                .font(.body.weight(.semibold))
                                .monospacedDigit()
                        }

                        Text(verbatim: item.caption)
                            .font(.telemetryCaption)
                            .foregroundStyle(Color(.systemGray))
                    } else {
                        HStack(spacing: 8) {
                            title

                            Spacer(minLength: 0)

                            EmptyBar(width: 28, height: 14)
                        }
                        .frame(height: 20)

                        EmptyBar(width: 74, height: 8)
                            .frame(height: 15, alignment: .leading)
                    }
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

    private var title: some View {
        Text(verbatim: item.kind.title)
            .font(.telemetryTitle)
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                TelemetryRow(item: TelemetryItem.sample[0], side: .leading, showsDivider: true, showsValues: true) {}
                TelemetryRow(item: TelemetryItem.sample[1], side: .trailing, showsDivider: false, showsValues: true) {}
                TelemetryRow(item: TelemetryItem.sample[2], side: .leading, showsDivider: true, showsValues: false) {}
                TelemetryRow(item: TelemetryItem.sample[3], side: .trailing, showsDivider: false, showsValues: false) {}
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
    }
}
