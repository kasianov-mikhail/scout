//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

extension View {
    @ViewBuilder
    func opaquePresentation() -> some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            presentationBackground(.background)
        } else {
            self
        }
    }
}
