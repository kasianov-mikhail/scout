//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct AlertActionButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(verbatim: title)
                .font(.scoutRowStrong)
                .foregroundStyle(color)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background {
                    RoundedRectangle(cornerRadius: .radiusBlock)
                        .stroke(Color.separator, lineWidth: 0.5)
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.solid)
    }
}
