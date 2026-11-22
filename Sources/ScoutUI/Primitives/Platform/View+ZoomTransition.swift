//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

extension View {
    @ViewBuilder
    func zoomSource(_ id: some Hashable, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            matchedTransitionSource(id: id, in: namespace)
        } else {
            self
        }
    }

    @ViewBuilder
    func zoomTransition(_ id: some Hashable, in namespace: Namespace.ID) -> some View {
        #if os(iOS)
            if #available(iOS 18.0, *) {
                navigationTransition(.zoom(sourceID: id, in: namespace))
            } else {
                self
            }
        #else
            self
        #endif
    }
}
