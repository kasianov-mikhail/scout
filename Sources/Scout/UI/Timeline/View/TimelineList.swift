//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct TimelineList<Pagination: View>: View {
    let items: [TimelineItem]
    let highlightedID: RecordID?

    @ViewBuilder let older: () -> Pagination
    @ViewBuilder let newer: () -> Pagination

    let timeline = Date()

    var body: some View {
        LazyVStack(spacing: 0) {
            older()

            ForEach(Array(items.enumerated()), id: \.element) { index, row in
                TimelineRow(
                    items: items,
                    index: index,
                    timeline: timeline,
                    highlighted: row.id == highlightedID
                )
            }

            newer()
        }
    }
}

#Preview {
    NavigationView {
        ScrollView {
            let items = TimelineItem.samples

            TimelineList(
                items: items,
                highlightedID: items.randomElement()?.id,
                older: { EmptyView() },
                newer: { EmptyView() }
            )
        }
    }
}
