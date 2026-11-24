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
            HStack(alignment: .top, spacing: .space8) {
                icon(width: 24)

                VStack(alignment: .leading, spacing: .space2) {
                    HStack(alignment: .firstTextBaseline, spacing: .space8) {
                        title

                        Spacer(minLength: 0)

                        Text(verbatim: item.valueLabel)
                            .font(.scoutTitle)
                            .monospacedDigit()
                    }

                    Text(verbatim: item.caption)
                        .font(.telemetryCaption)
                        .foregroundStyle(Color.textMuted)
                }
            }
        } else {
            HStack(alignment: .center, spacing: .space8) {
                icon(width: 22)

                VStack(alignment: .leading, spacing: .space6) {
                    title

                    GeometryReader { proxy in
                        EmptyBar(width: proxy.size.width * 0.6, height: 8)
                    }
                    .frame(height: 8)
                }

                EmptyBar(width: 28, height: 14)
            }
        }
    }

    private func icon(width: CGFloat) -> some View {
        Image(systemName: item.kind.systemImage)
            .font(.book(size: 16))
            .foregroundStyle(item.kind.color)
            .frame(width: width)
            .accessibilityHidden(true)
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
            .padding(.horizontal, .gutter)
        }
        .scrollIndicators(.hidden)
    }
}
