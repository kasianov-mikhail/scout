//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreGraphics
import Testing

@testable import ScoutCore
@testable import ScoutTestSupport
@testable import ScoutUI

@Suite("FlowLayout.arrange")
struct FlowLayoutTests {
    let layout = FlowLayout(spacing: 6)

    private func size(_ width: CGFloat, _ height: CGFloat) -> CGSize {
        CGSize(width: width, height: height)
    }

    @Test("a single item sits at the origin and claims the proposed width")
    func singleItem() {
        let result = layout.arrange([size(40, 20)], in: 200)
        #expect(result.positions == [CGPoint(x: 0, y: 0)])
        #expect(result.size == size(200, 20))
    }

    @Test("items that fit share a row, offset by width plus spacing")
    func fitsInOneRow() {
        let result = layout.arrange([size(40, 20), size(50, 20)], in: 200)
        #expect(result.positions == [CGPoint(x: 0, y: 0), CGPoint(x: 46, y: 0)])
        #expect(result.size.height == 20)
    }

    @Test("an overflowing item wraps to the next row")
    func wrapsToNextRow() {
        let result = layout.arrange([size(120, 20), size(120, 30)], in: 200)
        #expect(result.positions[0] == CGPoint(x: 0, y: 0))
        #expect(result.positions[1] == CGPoint(x: 0, y: 26))
        #expect(result.size.height == 56)
    }

    @Test("row height follows the tallest item before a wrap")
    func rowHeightUsesTallest() {
        let result = layout.arrange([size(40, 18), size(40, 40), size(180, 10)], in: 200)
        #expect(result.positions[2].y == 46)
    }

    @Test("an item wider than the container stays on its empty row")
    func oversizedItemStays() {
        let result = layout.arrange([size(500, 20)], in: 200)
        #expect(result.positions == [CGPoint(x: 0, y: 0)])
    }

    @Test("no items produce no positions and zero height")
    func empty() {
        let result = layout.arrange([], in: 200)
        #expect(result.positions.isEmpty)
        #expect(result.size.height == 0)
    }

    @Test("an unbounded width keeps one row and reports the content width")
    func intrinsicWidth() {
        let result = layout.arrange([size(40, 20), size(50, 20)], in: .infinity)
        #expect(result.positions[1].y == 0)
        #expect(result.size.width == 96)
    }

    @Test("spacing widens the gap and the reported bounds")
    func spacingHonored() {
        let wide = FlowLayout(spacing: 20)
        let result = wide.arrange([size(30, 10), size(30, 10)], in: .infinity)
        #expect(result.positions[1].x == 50)
        #expect(result.size.width == 80)
    }
}
