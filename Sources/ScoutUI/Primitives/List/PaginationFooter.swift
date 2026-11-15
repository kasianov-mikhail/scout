//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct PaginationFooter: View {
    let action: () async -> Bool

    @State private var page = 0
    @State private var hasFailed = false

    var body: some View {
        content
            .frame(height: 68)
            .frame(maxWidth: .infinity)
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
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            PaginationFooter {
                try? await Task.sleep(for: .seconds(60))
                return true
            }
        }
        .padding(.horizontal, .gutter)
    }
    .scrollIndicators(.hidden)
}

#Preview("Failed") {
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            PaginationFooter { false }
        }
        .padding(.horizontal, .gutter)
    }
    .scrollIndicators(.hidden)
}
