//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct RecenterButton: View {
    let direction: RecenterDirection
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            let icon = Image(systemName: direction.symbol)
                .font(.title3)
                .padding(12)
            #if compiler(>=6.2)
                if #available(iOS 26.0, *) {
                    icon.glassEffect(.regular.interactive(), in: Circle())
                } else {
                    icon.background(Circle().fill(.regularMaterial))
                }
            #else
                icon.background(Circle().fill(.regularMaterial))
            #endif
        }
        .padding(20)
        .transition(.scale.combined(with: .opacity))
    }
}
