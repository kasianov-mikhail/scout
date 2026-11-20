//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

struct AccountGate<Content: View>: View {
    let backend: Backend
    @ViewBuilder let content: () -> Content

    @StateObject private var provider = AccountProvider()

    var body: some View {
        Group {
            if let issue = provider.issue {
                AccountUnavailableView(issue: issue, endpoint: backend.id)
            } else if provider.isResolved {
                content()
            } else {
                Color.surface
            }
        }
        .task(id: backend.id) {
            await provider.probe(backend)
            await backend.changeSource?.start()
        }
        .onReceive(NotificationCenter.default.publisher(for: AppLifecycle.willEnterForeground)) { _ in
            Task {
                await provider.probe(backend)
            }
        }
    }
}
