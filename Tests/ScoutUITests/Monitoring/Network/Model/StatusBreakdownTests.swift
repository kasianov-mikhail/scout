//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Testing

@testable import ScoutCore
@testable import ScoutUI

@Suite("StatusBreakdown")
struct StatusBreakdownTests {
    @Test("add accumulates counts and total")
    func add() {
        var breakdown = StatusBreakdown()
        breakdown.add(count: 3, at: 0)
        breakdown.add(count: 2, at: 0)
        breakdown.add(count: 5, at: 3)

        #expect(breakdown.counts == [5, 0, 0, 5])
        #expect(breakdown.total == 10)
    }

    @Test("add ignores out-of-bounds indexes")
    func addOutOfBounds() {
        var breakdown = StatusBreakdown()
        breakdown.add(count: 7, at: 4)
        breakdown.add(count: 7, at: -1)

        #expect(breakdown.total == 0)
    }

    @Test("+ sums bucket-wise")
    func plus() {
        let sum = StatusBreakdown.sample(success: 1, redirect: 2) + .sample(success: 10, serverError: 3)

        #expect(sum.counts == [11, 2, 0, 3])
    }

    @Test("successRate counts 4xx and 5xx as failures")
    func successRate() {
        let breakdown = StatusBreakdown.sample(success: 90, redirect: 6, clientError: 3, serverError: 1)

        #expect(abs(breakdown.successRate.value - 0.96) < 0.000001)
    }

    @Test("segments pair every class with its count")
    func segments() {
        let segments = StatusBreakdown.sample(success: 8, redirect: 4, clientError: 2, serverError: 1).segments

        #expect(segments.map(\.label) == ["2xx", "3xx", "4xx", "5xx"])
        #expect(segments.map(\.count) == [8, 4, 2, 1])
    }
}
