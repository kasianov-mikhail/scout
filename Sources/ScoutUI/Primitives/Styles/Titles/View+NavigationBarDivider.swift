//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    func navigationBarDivider(_ color: Color?) -> some View {
        #if os(iOS)
            safeAreaInset(edge: .top, spacing: 0) {
                if let color {
                    Separator(color: color)
                }
            }
        #else
            self
        #endif
    }
}
