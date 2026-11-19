//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    func inlineNavigationTitle(divider: Color? = .lineSubtle) -> some View {
        #if os(iOS)
            navigationBarTitleDisplayMode(.inline)
                .navigationBarDivider(divider)
        #else
            self
        #endif
    }
}

extension View {
    func navigationTitle(en title: String) -> some View {
        navigationTitle(Text(verbatim: title))
    }
}
