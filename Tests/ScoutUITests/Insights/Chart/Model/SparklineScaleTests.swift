//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutCore
@testable import ScoutUI

struct SparklineScaleTests {
    @Test("The domain pads the values on both sides")
    func padsSpread() {
        let scale = SparklineScale(values: [10, 20])

        #expect(scale.bottom == 8.5)
        #expect(scale.top == 21.5)
    }

    @Test("A flat series still gets room to breathe")
    func flatSeries() {
        let scale = SparklineScale(values: [5, 5, 5])

        #expect(scale.bottom == 4.85)
        #expect(scale.top == 5.15)
    }

    @Test("An empty series falls back to a unit domain")
    func emptySeries() {
        let scale = SparklineScale(values: [])

        #expect(scale.bottom < 0)
        #expect(scale.top > 1)
    }

    @Test("The domain runs from bottom to top")
    func domain() {
        let scale = SparklineScale(values: [1, 9])

        #expect(scale.domain == scale.bottom...scale.top)
    }
}
