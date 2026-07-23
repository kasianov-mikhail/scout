//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    func rotatingProviders(_ providers: [any Provider]) -> some View {
        modifier(RotatingProvidersModifier(providers: providers))
    }
}

private struct RotatingProvidersModifier: ViewModifier {
    @Environment(\.database) var database

    let providers: [any Provider]

    func body(content: Content) -> some View {
        if let error = providers.compactMap(\.error).first {
            ErrorView(description: error.localizedDescription) {
                for provider in providers {
                    await provider.fetchIfFailed(in: database)
                }
            }
        } else {
            content
                .task { await providers.fetchIfNeeded(in: database) }
                .autoRefresh(rotating: refreshers, primesOnAppear: false)
        }
    }

    private var refreshers: [RefreshAction] {
        providers.map { provider in
            { await provider.fetchLatest(in: database) }
        }
    }
}
