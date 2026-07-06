//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct TimelineRow: View {
    let timeline: Date
    let highlighted: Bool
    let row: TimelineItem
    let prev: TimelineItem?
    let next: TimelineItem?
    let showsSeparator: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                ForEach(LegendKind.allCases, id: \.self) { kind in
                    TimelineSegment(kind: kind, row: row, prev: prev, next: next)
                }

                Text(row.name)
                    .font(.body)
                    .lineLimit(1)
                    .monospaced()
                    .padding(.leading, 8)

                Spacer()

                RelativeTimeText(date: row.date, timeline: timeline)
            }
            .frame(height: 43)
            .padding(.horizontal, 16)
            .background {
                if highlighted {
                    Color.accentColor.opacity(0.12)
                    GeometryReader { geo in
                        Color.clear.preference(key: AnchorFrameKey.self, value: geo.frame(in: .global))
                    }
                }
            }

            if showsSeparator {
                Divider()
                    .padding(.leading, 16 + CGFloat(LegendKind.allCases.count) * 16 + 20)
                    .padding(.trailing, 16)
            }
        }
    }
}

extension TimelineRow {
    init(items: [TimelineItem], index: Int, timeline: Date, highlighted: Bool) {
        self.timeline = timeline
        self.highlighted = highlighted
        self.row = items[index]
        self.prev = items[safe: index - 1]
        self.next = items[safe: index + 1]
        self.showsSeparator = index < items.count - 1
    }
}

#Preview {
    let items = TimelineItem.samples

    VStack(spacing: 0) {
        ForEach(Array(items.enumerated()), id: \.element) { index, row in
            TimelineRow(
                items: items,
                index: index,
                timeline: Date(),
                highlighted: index == 1
            )
        }
    }
}
