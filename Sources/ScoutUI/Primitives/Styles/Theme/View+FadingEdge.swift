//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    func fadingEdge(width: CGFloat) -> some View {
        mask(alignment: .trailing) {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(.black)
                LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                    .frame(width: width)
            }
        }
    }
}

#Preview {
    Text(verbatim: "A long line that runs out of room and fades")
        .lineLimit(1)
        .frame(width: 180)
        .fadingEdge(width: 28)
}
