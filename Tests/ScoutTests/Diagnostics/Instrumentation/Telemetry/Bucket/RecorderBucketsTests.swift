//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import Scout

@Suite("RecorderBuckets")
struct RecorderBucketsTests {
    @Test("Categories cover every bound plus overflow")
    func categories() {
        #expect(RecorderBuckets.categories.count == RecorderBuckets.bounds.count + 1)
        #expect(RecorderBuckets.categories.first == "recorder_le_1")
        #expect(RecorderBuckets.categories.last == "recorder_le_inf")
    }

    @Test("category(for:) picks the first bound at or above the sample")
    func binning() {
        #expect(RecorderBuckets.category(for: 0) == "recorder_le_1")
        #expect(RecorderBuckets.category(for: 1) == "recorder_le_1")
        #expect(RecorderBuckets.category(for: 1.5) == "recorder_le_2")
        #expect(RecorderBuckets.category(for: 100) == "recorder_le_100")
        #expect(RecorderBuckets.category(for: 3_700) == "recorder_le_5000")
        #expect(RecorderBuckets.category(for: 2_000_000) == "recorder_le_inf")
    }

    @Test("upperBound(of:) parses finite bucket categories only")
    func upperBound() {
        #expect(RecorderBuckets.upperBound(of: "recorder_le_500") == 500)
        #expect(RecorderBuckets.upperBound(of: "recorder_le_inf") == nil)
        #expect(RecorderBuckets.upperBound(of: "recorder") == nil)
    }

    @Test("index(of:) maps categories to histogram slots")
    func index() {
        #expect(RecorderBuckets.index(of: "recorder_le_1") == 0)
        #expect(RecorderBuckets.index(of: "recorder_le_inf") == RecorderBuckets.bounds.count)
        #expect(RecorderBuckets.index(of: "recorder") == nil)
    }
}
