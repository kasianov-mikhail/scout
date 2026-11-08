//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct TimelineList<Pagination: View>: View {
    let entries: [TimelineEntry]
    let focusID: String?

    @ViewBuilder let older: () -> Pagination
    @ViewBuilder let newer: () -> Pagination

    var body: some View {
        LazyVStack(spacing: 0) {
            Color.clear.frame(height: 8)

            older()

            ForEach(entries) { entry in
                TimelineRow(entry: entry)
                    .id(entry.id)
            }

            newer()
        }
        .anchoredScroll(id: isFocusLoaded ? focusID : nil, revision: entries.count)
    }

    private var isFocusLoaded: Bool {
        guard let focusID else {
            return false
        }
        return entries.contains { $0.id == focusID }
    }
}

#Preview {
    TimelineList(
        entries: [],
        focusID: nil,
        older: { EmptyView() },
        newer: { EmptyView() }
    )
}
