//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

extension View {
    /// Gives a sheet an opaque system background, overriding the translucent
    /// material newer OS versions apply by default.
    ///
    @ViewBuilder
    func opaquePresentationBackground() -> some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            presentationBackground(.background)
        } else {
            self
        }
    }
}
