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
    /// Stops a scroll view from bouncing when its content already fits, so a
    /// non-scrolling list can't be pulled into an empty overscroll area — which
    /// also blocks any pull-to-refresh inherited from a host view's environment.
    ///
    @ViewBuilder
    func disabledBounce() -> some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            scrollBounceBehavior(.basedOnSize)
        } else {
            self
        }
    }
}
