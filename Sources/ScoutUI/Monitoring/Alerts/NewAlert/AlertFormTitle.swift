//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

extension View {
    func alertFormTitle(title: String, isMonospaced: Bool) -> some View {
        modifier(AlertFormTitle(title: title, isMonospaced: isMonospaced))
    }
}

private struct AlertFormTitle: ViewModifier {
    let title: String
    let isMonospaced: Bool

    @ViewBuilder func body(content: Content) -> some View {
        if isMonospaced {
            content.monospacedNavigationTitle(en: title)
        } else {
            content.navigationTitle(en: title).inlineNavigationTitle()
        }
    }
}
