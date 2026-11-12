//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct OutlineChip: View {
    let text: String
    var monospaced = false

    var body: some View {
        Text(verbatim: text)
            .font(.scoutCaption)
            .monospaced(monospaced)
            .lineLimit(1)
            .padding(.horizontal, .space8)
            .frame(height: 26)
            .overlay {
                Capsule().stroke(Color.lineSubtle, lineWidth: .hairline)
            }
    }
}

#Preview {
    HStack(spacing: .space6) {
        OutlineChip(text: "iPhone 15 Pro")
        OutlineChip(text: "2.4.1 (214)", monospaced: true)
    }
}
