//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct HomeTypographySwitcher: View {
    @Binding var stored: String
    @Binding var isVisible: Bool

    let typography: HomeTypography

    var body: some View {
        if isVisible {
            bar
        } else {
            handle
        }
    }

    private var bar: some View {
        HStack(spacing: .space4) {
            arrow(systemImage: "chevron.left") {
                step(-1)
            }

            Text(verbatim: typography.label)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture(count: 2) {
                    isVisible = false
                }
                .onLongPressGesture {
                    isVisible = false
                }
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel(Text(verbatim: "Typography variant \(typography.id)"))
                .accessibilityHint(Text(verbatim: "Double-tap or touch and hold to hide the switcher"))

            arrow(systemImage: "chevron.right") {
                step(1)
            }
        }
        .frame(height: 30)
        .padding(.horizontal, .gutter)
        .background(Color.surface)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.separator)
                .frame(height: .hairline)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 16)
                .onEnded { value in
                    if value.translation.width < -16 {
                        step(1)
                    } else if value.translation.width > 16 {
                        step(-1)
                    }
                }
        )
    }

    private var handle: some View {
        Button {
            isVisible = true
        } label: {
            Capsule()
                .fill(Color.lineSeparator)
                .frame(width: 44, height: 4)
                .padding(.vertical, 6)
                .padding(.horizontal, 16)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onLongPressGesture {
            isVisible = true
        }
        .accessibilityLabel(Text(verbatim: "Show typography switcher"))
    }

    private func arrow(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .semibold))
                .frame(width: 32, height: 30)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.textLink)
    }

    private func step(_ delta: Int) {
        let variants = HomeTypography.variants
        let current = variants.firstIndex { $0.id == stored } ?? 0
        let next = (current + delta + variants.count) % variants.count
        stored = variants[next].id
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    @Previewable @State var stored = HomeTypography.v07.id
    @Previewable @State var isVisible = true

    VStack(spacing: 0) {
        HomeTypographySwitcher(stored: $stored, isVisible: $isVisible, typography: HomeTypography.variant(id: stored))
        Spacer()
    }
}
