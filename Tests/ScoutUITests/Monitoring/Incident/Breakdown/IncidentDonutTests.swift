//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI
import Testing

@testable import Scout
@testable import ScoutUI

@Suite("IncidentDonut segments")
struct IncidentDonutTests {
    private let segments = [
        Segment(label: "A", count: 5, color: .blue),
        Segment(label: "B", count: 3, color: .indigo),
        Segment(label: "C", count: 2, color: .purple),
    ]

    @Test("Sums segment counts into a total")
    func total() {
        #expect(segments.total == 10)
        #expect([Segment]().total == 0)
    }

    @Test("Maps an angle value to the segment covering it")
    func segmentAtAngle() {
        #expect(segments.segment(at: 0)?.label == "A")
        #expect(segments.segment(at: 4.9)?.label == "A")
        #expect(segments.segment(at: 5)?.label == "B")
        #expect(segments.segment(at: 7.9)?.label == "B")
        #expect(segments.segment(at: 8)?.label == "C")
        #expect(segments.segment(at: 9.9)?.label == "C")
    }

    @Test("Clamps an out-of-range angle to the last segment")
    func segmentBeyondTotal() {
        #expect(segments.segment(at: 42)?.label == "C")
        #expect([Segment]().segment(at: 0) == nil)
    }

    @Test("Formats a segment share as a whole percent")
    func percent() {
        #expect(segments.percent(of: segments[0]) == "50%")
        #expect(segments.percent(of: segments[2]) == "20%")
    }

    @Test("Returns zero percent when the total is empty")
    func percentOfEmpty() {
        #expect([Segment]().percent(of: segments[0]) == "0%")
    }
}
