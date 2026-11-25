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
            content
                .padding(.leading, side == .trailing ? 12 : 0)
                .padding(.trailing, side == .leading ? 12 : 0)
                .frame(height: 66)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .overlay(alignment: .bottom) {
                    if showsDivider {
                        Separator()
                    }
                }
        }
        .buttonStyle(.solid)
    }

    @ViewBuilder
    private var content: some View {
        if showsValues {
            VStack(alignment: .leading, spacing: .space2) {
                HStack(alignment: .firstTextBaseline, spacing: .space8) {
                    titleWithIcon

                    Spacer(minLength: 0)

                    Text(verbatim: item.valueLabel)
                        .font(.scoutTitle)
                        .monospacedDigit()
                }

                Text(verbatim: item.caption)
                    .font(.telemetryCaption)
                    .foregroundStyle(Color.textMuted)
                    .padding(.leading, iconWidth + .space8)
            }
        } else {
            HStack(alignment: .center, spacing: .space8) {
                VStack(alignment: .leading, spacing: .space6) {
                    titleWithIcon

                    GeometryReader { proxy in
                        EmptyBar(width: proxy.size.width * 0.6, height: 8)
                    }
                    .frame(height: 8)
                    .padding(.leading, iconWidth + .space8)
                }

                EmptyBar(width: 28, height: 14)
            }
        }
    }

    private var iconWidth: CGFloat {
        showsValues ? 24 : 22
    }

    private var titleWithIcon: some View {
        HStack(spacing: .space8) {
            Image(systemName: item.kind.systemImage)
                .font(.book(size: 16))
                .foregroundStyle(item.kind.color)
                .frame(width: iconWidth)
                .accessibilityHidden(true)

            Text(verbatim: item.kind.title)
                .font(.telemetryTitle)
        }
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
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}
