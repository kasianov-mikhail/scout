//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    /// English-only navigation title; bypasses host-app `LocalizedStringKey` resolution.
    func navigationTitle(en title: String) -> some View {
        navigationTitle(Text(verbatim: title))
    }
}
