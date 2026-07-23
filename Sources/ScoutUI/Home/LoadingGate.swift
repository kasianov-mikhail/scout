//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    func loadingGate(_ providers: [any Provider]) -> some View {
        modifier(LoadingGateModifier(providers: providers))
    }
}

private struct LoadingGateModifier: ViewModifier {
    let providers: [any Provider]

    func body(content: Content) -> some View {
        if providers.contains(where: \.isLoading) {
            RingIndicator().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            content
        }
    }
}

extension Provider {
    fileprivate var isLoading: Bool {
        result == nil
    }
}
