//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    func inlineNavigationTitle() -> some View {
        #if os(iOS)
            navigationBarTitleDisplayMode(.inline)
        #else
            self
        #endif
    }
}
