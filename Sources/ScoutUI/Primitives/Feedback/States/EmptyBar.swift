//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct EmptyBar: View {
    var width: CGFloat?
    let height: CGFloat
    var cornerRadius: CGFloat = 3

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(Color.lineSubtle, style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
            .frame(width: width, height: height)
            .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: .space8) {
        EmptyBar(width: 150, height: 26, cornerRadius: .radiusBadge)
        EmptyBar(height: 18)
        EmptyBar(width: 48, height: 10)
    }
    .padding()
}
