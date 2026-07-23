//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    func rotatingProviders(first: [any Provider], later: [any Provider]) -> some View {
        modifier(RotatingProvidersModifier(first: first, later: later))
    }
}

private struct RotatingProvidersModifier: ViewModifier {
    @Environment(\.database) var database

    let first: [any Provider]
    let later: [any Provider]

    func body(content: Content) -> some View {
        if let error = providers.compactMap(\.error).first {
            ErrorView(description: error.localizedDescription) {
                for provider in providers {
                    await provider.fetchIfFailed(in: database)
                }
            }
        } else {
            content.periodRefresh(first: first, later: later)
        }
    }

    private var providers: [any Provider] {
        first + later
    }
}
