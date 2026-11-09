//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI
import Testing

@testable import ScoutUI

@Suite("Segment")
struct SegmentTests {
    @Test("Sums segment counts into a total")
    func total() {
        let segments = [5, 3, 2].enumerated().map { index, count in
            Segment(label: "L\(index)", count: count, color: .blue)
        }

        #expect(segments.total == 10)
        #expect([Segment]().total == 0)
    }
}
