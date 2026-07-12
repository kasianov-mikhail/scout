//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

struct TimelineSegment: View {
    let color: Color
    let isActive: Bool
    let topRadius: CGFloat
    let bottomRadius: CGFloat

    var body: some View {
        UnevenRoundedRectangle(
            topLeadingRadius: topRadius,
            bottomLeadingRadius: bottomRadius,
            bottomTrailingRadius: bottomRadius,
            topTrailingRadius: topRadius
        )
        .fill(color.opacity(isActive ? 1 : 0.08))
        .frame(width: 8)
        .padding(.top, topRadius > 0 ? 2 : 0)
        .padding(.bottom, bottomRadius > 0 ? 2 : 0)
        .frame(width: 16)
    }
}

extension TimelineSegment {
    init(kind: LegendKind, row: TimelineItem, prev: TimelineItem?, next: TimelineItem?) {
        let active = row.active.contains(kind)

        self.color = kind.color
        self.isActive = active
        self.topRadius = (active && !connected(prev, row, on: kind)) ? 4 : 0
        self.bottomRadius = (active && !connected(next, row, on: kind)) ? 4 : 0
    }
}
