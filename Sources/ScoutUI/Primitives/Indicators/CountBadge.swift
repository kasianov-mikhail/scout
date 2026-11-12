//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct CountBadge: View {
    let count: Int
    var prefix: String = ""
    var suffix: String = ""
    var color: Color = .fillDanger

    var body: some View {
        Text(verbatim: "\(prefix)\(count)\(suffix)")
            .font(.scoutFootnoteStrong)
            .monospacedDigit()
            .foregroundStyle(color)
            .padding(.horizontal, .space6)
            .padding(.vertical, .space2)
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: .radiusBadge))
    }
}
