//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

struct TimelineList<Pagination: View>: View {
    let items: [TimelineItem]
    var highlightedID: CKRecord.ID? = nil

    @ViewBuilder let older: () -> Pagination
    @ViewBuilder let newer: () -> Pagination

    let timeline = Date()

    @State private var scrollID: CKRecord.ID?

    var body: some View {
        if #available(iOS 17.0, *) {
            ScrollView {
                stack.scrollTargetLayout()
            }
            .scrollPosition(id: $scrollID, anchor: .center)
            .onAppear { scrollID = highlightedID }
        } else {
            ScrollView { stack }
        }
    }

    @ViewBuilder
    private var stack: some View {
        LazyVStack(spacing: 0) {
            older()

            ForEach(Array(items.enumerated()), id: \.element.id) { index, row in
                TimelineRow(
                    color: row.isCrash ? .red : .primary,
                    name: row.name,
                    date: row.date,
                    timeline: timeline
                ) {
                    ForEach(LegendKind.allCases, id: \.self) { kind in
                        let prev = items[safe: index - 1]
                        let next = items[safe: index + 1]

                        TimelineSegment(
                            color: kind.color,
                            isActive: row.active.contains(kind),
                            prevActive: connected(prev, row, on: kind),
                            nextActive: connected(next, row, on: kind)
                        )
                    }
                }
                .background {
                    if row.id == highlightedID {
                        // Bleed past the stack's 16pt inset so the tint spans
                        // edge to edge, like warning/error rows in EventList.
                        Color.accentColor.opacity(0.12).padding(.horizontal, -16)
                    }
                }

                if let next = items[safe: index + 1], sameSection(row, next) {
                    Divider().padding(.leading, CGFloat(LegendKind.allCases.count) * 16 + 8)
                }
            }

            newer()
        }
        .padding(16)
    }
}

#Preview {
    NavigationView {
        TimelineList(
            items: TimelineItem.samples,
            highlightedID: TimelineItem.samples.randomElement()?.id,
            older: { EmptyView() },
            newer: { EmptyView() }
        )
    }
}
