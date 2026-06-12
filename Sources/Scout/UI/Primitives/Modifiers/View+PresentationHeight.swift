//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    /// Gives a sheet a fixed height: a detent on iOS, an explicit golden-ratio
    /// frame on macOS, where sheets have no detents.
    ///
    func presentationHeight(_ height: CGFloat) -> some View {
        #if os(iOS)
            presentationDetents([.height(height)])
        #else
            frame(width: height / 1.618, height: height)
        #endif
    }
}
