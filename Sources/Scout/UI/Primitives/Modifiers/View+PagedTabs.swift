//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    /// Paged tabs with always-visible page dots on iOS; the default tab style
    /// on macOS, which has no page style.
    ///
    func pagedTabs() -> some View {
        #if os(iOS)
            tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
        #else
            self
        #endif
    }
}
