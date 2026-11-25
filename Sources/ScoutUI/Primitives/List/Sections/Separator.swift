//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct Separator: View {
    @Environment(\.pixelLength) private var pixelLength

    var axis = Axis.horizontal
    var color = Color.separator
    var isDashed = false

    static var dashed: Separator {
        Separator(color: .lineSubtle, isDashed: true)
    }

    private var thickness: CGFloat {
        // A half point spans 1.5 pixels at 3×. Use a whole number of pixels
        // so equivalent lines render with the same weight at different positions.
        max(1, (CGFloat.hairline / pixelLength).rounded()) * pixelLength
    }

    var body: some View {
        Group {
            if isDashed {
                Canvas { context, size in
                    let y = size.height / 2
                    let line = Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }
                    context.stroke(line, with: .color(color), style: StrokeStyle(lineWidth: thickness, dash: [3, 3]))
                }
            } else {
                Rectangle().fill(color)
            }
        }
        .frame(width: axis == .vertical ? thickness : nil, height: axis == .horizontal ? thickness : nil)
        // Preserve the coverage of the design hairline after rounding its width.
        .opacity(CGFloat.hairline / thickness)
        .allowsHitTesting(false)
    }
}

#Preview {
    VStack(spacing: .space16) {
        Separator()
        Separator(color: .lineGap)
        HStack(spacing: .space16) {
            Text(verbatim: "Left")
            Separator(axis: .vertical).frame(height: 40)
            Text(verbatim: "Right")
        }
    }
    .padding()
}
