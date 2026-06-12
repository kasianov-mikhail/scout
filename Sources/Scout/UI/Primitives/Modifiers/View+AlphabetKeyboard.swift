//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    /// Plain alphabet keyboard on iOS to stop keyboard suggestions; no-op on macOS.
    func alphabetKeyboard() -> some View {
        #if os(iOS)
            keyboardType(.alphabet)
        #else
            self
        #endif
    }
}
