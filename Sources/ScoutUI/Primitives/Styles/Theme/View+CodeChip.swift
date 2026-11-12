//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    func codeChipStyle() -> some View {
        font(.codeChip)
            .foregroundStyle(Color.textPrimary)
            .padding(.horizontal, .space12)
            .padding(.vertical, .space10)
            .background(
                RoundedRectangle(cornerRadius: .radiusBadge)
                    .fill(Color.surfaceGrey)
            )
    }
}
