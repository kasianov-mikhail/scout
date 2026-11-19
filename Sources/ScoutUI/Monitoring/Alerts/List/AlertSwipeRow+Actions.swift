//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension AlertSwipeRow {
    var actions: some View {
        ZStack {
            if displayOffset > 0, let onMute {
                actionButton(color: Color.textWarning, icon: "bell.slash", side: .trailing) {
                    perform(direction: 1, action: onMute)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if displayOffset < 0 {
                actionButton(color: Color.textDanger, icon: "trash", side: .leading) {
                    perform(direction: -1, action: onDelete)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private func actionButton(color: Color, icon: String, side: SwipeSide, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Capsule()
                .fill(color)
                .frame(width: capsuleWidth, height: swipeActionSize)
                .overlay(alignment: side.alignment) {
                    Image(systemName: icon)
                        .font(.scoutBody)
                        .foregroundStyle(Color.textOnFill)
                        .padding(side.iconPadding, 14)
                }
        }
        .buttonStyle(.plain)
        .frame(maxHeight: .infinity)
        .contentShape(Rectangle())
        .padding(side.buttonPadding, 12)
        .opacity(capsuleOpacity)
        .accessibilityLabel(Text(verbatim: side.label))
    }
}
