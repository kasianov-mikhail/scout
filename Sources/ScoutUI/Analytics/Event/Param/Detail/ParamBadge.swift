//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

/// A capsule naming the recognized scalar kind.
struct ParamBadge: View {
    let convertible: ParamValue.Convertible

    var body: some View {
        Label(convertible.label, systemImage: convertible.iconName)
            .font(.caption.weight(.medium))
            .foregroundStyle(convertible.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(convertible.color.opacity(0.13), in: Capsule())
    }
}
