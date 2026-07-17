//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import ScoutCore
@testable import ScoutTestSupport

@Suite("LatencyBuckets")
struct LatencyBucketsTests {
    @Test("Categories cover every bound plus overflow")
    func categories() {
        #expect(LatencyBuckets.categories.count == LatencyBuckets.boundsMilliseconds.count + 1)
        #expect(LatencyBuckets.categories.first == "timer_le_1")
        #expect(LatencyBuckets.categories.last == "timer_le_inf")
    }

    @Test("category(for:) picks the first bound at or above the sample")
    func binning() {
        #expect(LatencyBuckets.category(for: 0.0005) == "timer_le_1")
        #expect(LatencyBuckets.category(for: 0.001) == "timer_le_1")
        #expect(LatencyBuckets.category(for: 0.0011) == "timer_le_2")
        #expect(LatencyBuckets.category(for: 0.1) == "timer_le_100")
        #expect(LatencyBuckets.category(for: 3.7) == "timer_le_5000")
        #expect(LatencyBuckets.category(for: 31) == "timer_le_inf")
    }

    @Test("upperBound(of:) parses finite bucket categories only")
    func upperBound() {
        #expect(LatencyBuckets.upperBound(of: "timer_le_250") == 0.25)
        #expect(LatencyBuckets.upperBound(of: "timer_le_inf") == nil)
        #expect(LatencyBuckets.upperBound(of: "counter") == nil)
    }

    @Test("index(of:) maps categories to histogram slots")
    func index() {
        #expect(LatencyBuckets.index(of: "timer_le_1") == 0)
        #expect(LatencyBuckets.index(of: "timer_le_inf") == LatencyBuckets.boundsMilliseconds.count)
        #expect(LatencyBuckets.index(of: "timer") == nil)
    }
}
