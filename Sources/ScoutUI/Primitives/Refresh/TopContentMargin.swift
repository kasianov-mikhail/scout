//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    @available(iOS 17.0, macOS 14.0, *)
    func topContentMargin(_ inset: CGFloat) -> some View {
        modifier(TopContentMarginModifier(inset: inset))
    }
}

// `contentMargins` is not animatable on its own; routing the inset through
// `animatableData` lets an animation feed it frame by frame.
@available(iOS 17.0, macOS 14.0, *)
private struct TopContentMarginModifier: ViewModifier, Animatable {
    var inset: CGFloat

    nonisolated var animatableData: CGFloat {
        get { inset }
        set { inset = newValue }
    }

    func body(content: Content) -> some View {
        content.contentMargins(.top, inset, for: .scrollContent)
    }
}
