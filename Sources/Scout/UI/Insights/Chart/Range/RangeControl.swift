//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RangeControl<T: ChartTimeScale>: View {
    @Binding var extent: ChartExtent<T>

    var body: some View {
        HStack(spacing: 0) {
            MoveButton(image: "chevron.left") {
                extent.moveLeft()
            }
            .disabled(!extent.isLeftEnabled)

            Text(extent.domain.label(using: rangeDateFormatter))
                .font(.callout)
                .monospaced()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity)

            MoveButton(image: "chevron.right") {
                extent.moveRight()
            }
            .simultaneousGesture(
                LongPressGesture().onEnded { _ in
                    extent.moveRightEdge()
                }
            )
            .disabled(!extent.isRightEnabled)
        }
        .frame(height: 44)
        .padding(.top)
        .padding(.horizontal)
        .hapticFeedback(.selection, trigger: extent.domain)
    }

    struct MoveButton: View {
        let image: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: image)
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(.tint.opacity(0.12)))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tint)
        }
    }
}

#Preview {
    RangeControl(
        extent: .constant(ChartExtent(period: Period.today))
    )
}
