//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Testing

@testable import Scout

@Suite("StatusBuckets")
struct StatusBucketsTests {
    @Test("category maps codes to their class bucket")
    func categoryForCode() {
        #expect(StatusBuckets.category(for: 200) == "status_2xx")
        #expect(StatusBuckets.category(for: 204) == "status_2xx")
        #expect(StatusBuckets.category(for: 301) == "status_3xx")
        #expect(StatusBuckets.category(for: 404) == "status_4xx")
        #expect(StatusBuckets.category(for: 599) == "status_5xx")
    }

    @Test("category rejects codes outside 200..<600")
    func categoryBounds() {
        #expect(StatusBuckets.category(for: 100) == nil)
        #expect(StatusBuckets.category(for: 199) == nil)
        #expect(StatusBuckets.category(for: 600) == nil)
        #expect(StatusBuckets.category(for: -1) == nil)
    }

    @Test("category reads the numeric status dimension")
    func categoryInDimensions() {
        #expect(StatusBuckets.category(in: [("status", "404")]) == "status_4xx")
        #expect(StatusBuckets.category(in: [("path", "/v1/events"), ("status", "200")]) == "status_2xx")
    }

    @Test("category ignores missing or non-numeric status dimensions")
    func categoryInDimensionsRejects() {
        #expect(StatusBuckets.category(in: []) == nil)
        #expect(StatusBuckets.category(in: [("path", "/v1/events")]) == nil)
        #expect(StatusBuckets.category(in: [("status", "2xx")]) == nil)
        #expect(StatusBuckets.category(in: [("status", "ok")]) == nil)
    }

    @Test("index round-trips every category and rejects foreign ones")
    func index() {
        for (offset, category) in StatusBuckets.categories.enumerated() {
            #expect(StatusBuckets.index(of: category) == offset)
        }
        #expect(StatusBuckets.index(of: "timer_le_1") == nil)
        #expect(StatusBuckets.index(of: "counter") == nil)
    }
}
