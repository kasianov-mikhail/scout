//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import SwiftUI
import Testing

@testable import Scout
@testable import ScoutUI

@Suite("SegmentBar legend fitting")
struct SegmentBarTests {
    private func makeSegments(_ counts: [Int], other: Int? = nil) -> [Segment] {
        var segments = counts.enumerated().map { index, count in
            Segment(label: "L\(index)", count: count, color: .blue)
        }
        if let other {
            segments.append(Segment(count: other, color: .gray, kind: .other))
        }
        return segments
    }

    private let chip: (Segment) -> CGFloat = { $0.kind == .other ? 4 : 10 }

    @Test("Keeps every segment when the legend already fits")
    func keepsFittingSegments() {
        let segments = makeSegments([5, 4, 3])

        let fitted = segments.fittingLegend(width: 100, spacing: 2, chipWidth: chip)

        #expect(fitted.map(\.label) == ["L0", "L1", "L2"])
    }

    @Test("Folds the overflowing tail into a single other segment")
    func foldsOverflowIntoOther() {
        let segments = makeSegments([5, 4, 3])

        let fitted = segments.fittingLegend(width: 30, spacing: 2, chipWidth: chip)

        #expect(fitted.map(\.label) == ["L0", "L1", "Other"])
        #expect(fitted.last?.count == 3)
    }

    @Test("Adds the folded counts to an existing other segment")
    func mergesIntoExistingOther() {
        let segments = makeSegments([5, 4], other: 6)

        let fitted = segments.fittingLegend(width: 20, spacing: 2, chipWidth: chip)

        #expect(fitted.map(\.label) == ["L0", "Other"])
        #expect(fitted.last?.count == 10)
    }

    @Test("Never folds away the last named segment")
    func keepsOneNamedSegment() {
        let segments = makeSegments([5, 4, 3])

        let fitted = segments.fittingLegend(width: 0, spacing: 2, chipWidth: chip)

        #expect(fitted.map(\.label) == ["L0", "Other"])
        #expect(fitted.last?.count == 7)
    }

    @Test("Leaves a lone segment untouched")
    func keepsLoneSegment() {
        let segments = makeSegments([5])

        let fitted = segments.fittingLegend(width: 0, spacing: 2, chipWidth: chip)

        #expect(fitted.map(\.label) == ["L0"])
    }

    @Test("Preserves the total count while folding")
    func preservesTotal() {
        let segments = makeSegments([9, 7, 5, 3], other: 1)

        let fitted = segments.fittingLegend(width: 24, spacing: 2, chipWidth: chip)

        #expect(fitted.reduce(0) { $0 + $1.count } == 25)
    }
}
