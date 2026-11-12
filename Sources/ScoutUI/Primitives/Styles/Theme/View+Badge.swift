//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

private let badgeCornerRadius: CGFloat = 4
private let badgeHorizontalPadding: CGFloat = 6
private let badgeVerticalPadding: CGFloat = 2

extension View {
    func badgeStyle(fill: Color) -> some View {
        padding(.horizontal, badgeHorizontalPadding)
            .padding(.vertical, badgeVerticalPadding)
            .background(fill, in: RoundedRectangle(cornerRadius: badgeCornerRadius))
    }
}
