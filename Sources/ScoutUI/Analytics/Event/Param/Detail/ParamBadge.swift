//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

struct ParamBadge: View {
    let convertible: ParamValue.Convertible

    var body: some View {
        Label(convertible.label, systemImage: convertible.iconName)
            .font(.scoutFootnote)
            .foregroundStyle(convertible.color)
            .padding(.horizontal, .space8)
            .padding(.vertical, .space4)
            .background(convertible.color.opacity(0.12), in: RoundedRectangle(cornerRadius: .radiusBadge))
    }
}
