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
    @Environment(\.database) private var database

    let providers: [any Provider]

    func body(content: Content) -> some View {
        Group {
            if providers.contains(where: \.isLoading) {
                RingIndicator().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                content
            }
        }
        .task {
            await withTaskGroup(of: Void.self) { group in
                for fetch in fetchers {
                    group.addTask { await fetch() }
                }
            }
        }
    }

    private var fetchers: [@MainActor () async -> Void] {
        providers.map { provider in
            { await provider.fetchIfNeeded(in: database) }
        }
    }
}

extension Provider {
    fileprivate var isLoading: Bool {
        result == nil
    }
}
