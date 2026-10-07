//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import LookupIndex
@testable import Scout

struct CacheableQueryTests {
    let range = Date(timeIntervalSince1970: 0)..<Date(timeIntervalSince1970: 1)

    @Test("Metric series fingerprint spell out every metric dimension")
    func metricFingerprint() {
        let query = MetricSeriesQuery(
            name: "Session",
            category: "http_status",
            values: .int,
            bucket: .hour,
            reduce: .last,
            range: range
        )

        #expect(query.fingerprint == "Session|http_status|int|hour|*|metric|last")
    }

    @Test("Lifecycle series fingerprint spell out the counter and the version split")
    func lifecycleFingerprint() {
        let query = LifecycleSeriesQuery.sessions(bucket: .hour, byVersion: true, range: range)

        #expect(query.fingerprint == "Session|*|*|hour|version|lifecycle|sum")
    }

    @Test("Series fingerprint ignore the range and fill absent dimensions with a wildcard")
    func wildcards() {
        let query = EventSeriesQuery(range: range)
        var shifted = query
        shifted.range = Date(timeIntervalSince1970: 5)..<Date(timeIntervalSince1970: 9)

        #expect(query.fingerprint == "*|*|*|day|*|event|sum")
        #expect(query.fingerprint == shifted.fingerprint)
    }
}
