//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

/// The colored kind icon of a value.
struct ParamIcon: View {
    let value: ParamValue

    var body: some View {
        Group {
            switch value.icon {
            case .symbol(let name):
                Image(systemName: name)
                    .font(.body)
            case .text(let text):
                Text(text)
                    .font(.body.weight(.semibold))
                    .fixedSize()
            }
        }
        .foregroundStyle(value.color)
        .frame(width: 24)
    }
}
