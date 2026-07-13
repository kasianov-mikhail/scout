//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Testing

@testable import Scout

@Suite("IncidentBreakdown")
struct IncidentBreakdownTests {
    @Test("Counts occurrences per label")
    func countsPerLabel() {
        let segments = IncidentBreakdown.segments(from: ["A", "A", "B"])

        #expect(Set(segments.map(\.label)) == ["A", "B"])
        #expect(segments.first { $0.label == "A" }?.count == 2)
        #expect(segments.first { $0.label == "B" }?.count == 1)
    }

    @Test("Orders segments by count descending")
    func ordersByCount() {
        let segments = IncidentBreakdown.segments(from: ["C", "A", "A", "B", "B", "B"])

        #expect(segments.map(\.label) == ["B", "A", "C"])
    }

    @Test("Buckets everything past the top cutoff into Other")
    func bucketsIntoOther() {
        let labels =
            Array(repeating: "A", count: 5) + Array(repeating: "B", count: 4) + Array(repeating: "C", count: 3)
            + Array(repeating: "D", count: 2)
            + Array(repeating: "E", count: 1)
        let segments = IncidentBreakdown.segments(from: labels, top: 4)

        #expect(segments.map(\.label) == ["A", "B", "C", "D", "Other"])
        #expect(segments.last?.count == 1)
    }

    @Test("Omits Other when everything fits within the top cutoff")
    func omitsOtherWhenNothingRemains() {
        let segments = IncidentBreakdown.segments(from: ["A", "B"], top: 4)

        #expect(segments.map(\.label) == ["A", "B"])
    }

    @Test("Returns no segments for empty input")
    func emptyInput() {
        #expect(IncidentBreakdown.segments(from: []).isEmpty)
    }
}
