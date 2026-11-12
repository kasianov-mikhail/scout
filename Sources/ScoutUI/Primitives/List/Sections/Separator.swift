//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct Separator: View {
    var axis = Axis.horizontal

    var body: some View {
        Rectangle()
            .fill(Color.separator)
            .frame(width: axis == .vertical ? 0.5 : nil, height: axis == .horizontal ? 0.5 : nil)
            .allowsHitTesting(false)
    }
}

#Preview {
    VStack(spacing: 16) {
        Separator()
        HStack(spacing: 16) {
            Text(verbatim: "Left")
            Separator(axis: .vertical)
                .frame(height: 40)
            Text(verbatim: "Right")
        }
    }
    .padding()
}
