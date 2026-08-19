//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

extension View {
    func refreshOnPull(_ providers: [any Refreshable]) -> some View {
        modifier(RefreshOnPullModifier(providers: providers))
    }

    func refreshes(_ providers: [any Refreshable]) -> some View {
        fetchTask(providers).refreshOnPull(providers)
    }
}

private struct RefreshOnPullModifier: ViewModifier {
    @Environment(\.database) private var database

    let providers: [any Refreshable]

    func body(content: Content) -> some View {
        content.pullToRefresh {
            await providers.fetchAgain(in: database)
        }
    }
}
