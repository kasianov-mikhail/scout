//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

struct PaginationFooter: View {
    let action: () async -> Bool

    // Counts the pages this footer has loaded. Bumping it re-runs the task so the
    // next page loads while the footer stays visible; leaving it alone after a
    // failure keeps the error in place instead of re-requesting on every redraw.
    @State private var page = 0
    @State private var hasFailed = false

    var body: some View {
        content
            .frame(height: 68)
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden, edges: .bottom)
    }

    @ViewBuilder private var content: some View {
        if hasFailed {
            ErrorRow(description: "Couldn't load more", retry: load)
        } else {
            RingIndicator(size: 22)
                .task(id: page) {
                    await load()
                }
        }
    }

    private func load() async {
        if await action() {
            hasFailed = false
            page += 1
        } else {
            hasFailed = true
        }
    }
}

#Preview("Loading") {
    InsetList {
        PaginationFooter { true }
    }
}

#Preview("Failed") {
    InsetList {
        PaginationFooter { false }
    }
}
