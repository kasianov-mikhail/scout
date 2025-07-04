//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RangeControl<T: ChartCompatible>: View {
    @Binding var model: StatModel<T>

    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        HStack {
            MoveButton(image: "chevron.left") {
                model.moveLeft()
            }
            .disabled(!model.isLeftEnabled)

            Text(model.range.rangeLabel(formatter: formatter))
                .font(.system(size: 16))
                .monospaced()
                .frame(height: 44)
                .frame(maxWidth: .infinity)

            MoveButton(image: "chevron.right") {
                model.moveRight()
            }
            .simultaneousGesture(
                LongPressGesture().onEnded { _ in
                    model.moveRightEdge()
                }
            )
            .disabled(!model.isRightEnabled)
        }
    }

    struct MoveButton: View {
        let image: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                Image(systemName: image)
            }
            .font(.system(size: 16))
            .frame(width: 44, height: 44)
        }
    }
}
