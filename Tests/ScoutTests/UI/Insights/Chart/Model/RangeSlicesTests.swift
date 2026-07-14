//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct RangeSlicesTests {
    let range = Date(year: 2026, month: 6, day: 1)..<Date(year: 2026, month: 6, day: 8)

    @Test("The range splits into equal slices, oldest first")
    func slices() {
        let slices = range.slices(count: 7)

        #expect(slices.count == 7)
        #expect(slices.first?.lowerBound == range.lowerBound)
        #expect(slices.last?.upperBound == range.upperBound)
    }

    @Test("Slices meet without a gap or an overlap")
    func adjacentSlices() {
        let slices = range.slices(count: 7)

        for (earlier, later) in zip(slices, slices.dropFirst()) {
            #expect(earlier.upperBound == later.lowerBound)
        }
    }

    @Test("An empty range has nothing to slice")
    func emptyRange() {
        let date = Date(year: 2026, month: 6, day: 1)

        #expect((date..<date).slices(count: 7).count == 0)
    }
}
