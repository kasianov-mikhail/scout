//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import Testing

@testable import ScoutUI

@Suite("ResourceSummary")
struct ResourceSummaryTests {
    @Test("Total sums every kind")
    func total() {
        let summary = ResourceSummary(counts: [.cpu: 3])

        #expect(summary.total == 3)
    }
}
