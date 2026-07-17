//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI
import Testing

@testable import ScoutCore
@testable import ScoutUI

struct ReferenceLevelTests {
    @Test("Drop means the previous level lies above the bar") func testIsDrop() {
        #expect(makeLevel(reference: 50).isDrop)
        #expect(!makeLevel(reference: 120).isDrop)
        #expect(!makeLevel(reference: 80).isDrop)
    }

    @Test("Gains and drops partition the levels") func testPartition() {
        let levels = [makeLevel(reference: 50), makeLevel(reference: 120)]

        #expect(levels.drops.map(\.reference) == [50])
        #expect(levels.gains.map(\.reference) == [120])
    }

    @Test("Slices fill between the two periods' levels") func testSlices() {
        #expect([makeLevel(reference: 50)].slices.boundingRect == CGRect(x: 10, y: 50, width: 20, height: 30))
        #expect([makeLevel(reference: 120)].slices.boundingRect == CGRect(x: 10, y: 80, width: 20, height: 40))
    }

    @Test("Lines run across the bar at the previous level") func testLines() {
        let path = [makeLevel(reference: 50)].lines

        #expect(path.elements == [.move(to: CGPoint(x: 10, y: 50)), .line(to: CGPoint(x: 30, y: 50))])
    }

    @Test("Contours rise to the previous level and cap the top") func testContours() {
        let path = [makeLevel(reference: 50)].contours

        #expect(
            path.elements == [
                .move(to: CGPoint(x: 10, y: 80)),
                .line(to: CGPoint(x: 10, y: 50)),
                .line(to: CGPoint(x: 30, y: 50)),
                .line(to: CGPoint(x: 30, y: 80)),
            ]
        )
    }

    @Test("Clamped contours leave the top cap open") func testClampedContours() {
        let path = [makeLevel(reference: 0, isClamped: true)].contours

        #expect(
            path.elements == [
                .move(to: CGPoint(x: 10, y: 80)),
                .line(to: CGPoint(x: 10, y: 0)),
                .move(to: CGPoint(x: 30, y: 0)),
                .line(to: CGPoint(x: 30, y: 80)),
            ]
        )
    }

    func makeLevel(reference: CGFloat, isClamped: Bool = false) -> ReferenceLevel {
        ReferenceLevel(
            x: 10...30,
            count: 80,
            reference: reference,
            isClamped: isClamped
        )
    }
}

extension Path {
    fileprivate var elements: [Element] {
        var elements: [Element] = []
        forEach { elements.append($0) }
        return elements
    }
}
