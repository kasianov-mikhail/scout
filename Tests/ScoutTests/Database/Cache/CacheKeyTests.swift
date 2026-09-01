//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct CacheKeyTests {
    let range = Date(timeIntervalSince1970: 0)..<Date(timeIntervalSince1970: 1)

    @Test("Lookup keys sort the requested fields and mark a full fetch")
    func lookupFingerprint() {
        let sorted = CacheKey.lookup(scope: "s", recordName: "event-1", fields: ["name", "date"]).fingerprint
        let reversed = CacheKey.lookup(scope: "s", recordName: "event-1", fields: ["date", "name"]).fingerprint
        let full = CacheKey.lookup(scope: "s", recordName: "event-1", fields: nil).fingerprint

        #expect(sorted == "s|lookup|event-1|date,name")
        #expect(sorted == reversed)
        #expect(full == "s|lookup|event-1|*")
    }

    @Test("Series keys spell out every query dimension")
    func seriesFingerprint() {
        let query = SeriesQuery(
            name: "Session",
            category: "http_status",
            values: .int,
            bucket: .hour,
            byVersion: true,
            source: .metric,
            reduce: .last,
            range: range
        )

        #expect(CacheKey.series(scope: "s", query: query).fingerprint == "s|series|Session|http_status|int|hour|version|metric|last")
    }

    @Test("Series keys ignore the range and fill absent dimensions with a wildcard")
    func seriesWildcards() {
        let query = SeriesQuery(range: range)
        var shifted = query
        shifted.range = Date(timeIntervalSince1970: 5)..<Date(timeIntervalSince1970: 9)

        #expect(CacheKey.series(scope: "s", query: query).fingerprint == "s|series|*|*|*|day|*|*|sum")
        #expect(CacheKey.series(scope: "s", query: query).fingerprint == CacheKey.series(scope: "s", query: shifted).fingerprint)
    }

    @Test("Lookup and series keys never collide")
    func namespaces() {
        let lookup = CacheKey.lookup(scope: "s", recordName: "series", fields: nil).fingerprint
        let series = CacheKey.series(scope: "s", query: SeriesQuery(range: range)).fingerprint

        #expect(lookup != series)
    }
}
