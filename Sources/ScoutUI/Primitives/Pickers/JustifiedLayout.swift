//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ScoutCore
import SwiftUI

struct JustifiedLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? subviews.reduce(0) { $0 + $1.sizeThatFits(.unspecified).width }
        let height = subviews.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count > 0 else { return }

        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let firstCenter = bounds.minX + (sizes.first?.width ?? 0) / 2
        let lastCenter = bounds.maxX - (sizes.last?.width ?? 0) / 2

        for index in subviews.indices {
            let fraction = subviews.count == 1 ? 0 : CGFloat(index) / CGFloat(subviews.count - 1)
            let centerX = firstCenter + fraction * (lastCenter - firstCenter)
            subviews[index].place(
                at: CGPoint(x: centerX, y: bounds.midY),
                anchor: .center,
                proposal: ProposedViewSize(sizes[index])
            )
        }
    }
}
