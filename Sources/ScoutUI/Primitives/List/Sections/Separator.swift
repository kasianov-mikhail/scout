//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct Separator: View {
    var axis = Axis.horizontal
    var color = Color.separator

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: axis == .vertical ? .hairline : nil, height: axis == .horizontal ? .hairline : nil)
            .allowsHitTesting(false)
    }
}

#Preview {
    VStack(spacing: .space16) {
        Separator()
        Separator(color: .lineGap)
        HStack(spacing: .space16) {
            Text(verbatim: "Left")
            Separator(axis: .vertical)
                .frame(height: 40)
            Text(verbatim: "Right")
        }
    }
    .padding()
}
