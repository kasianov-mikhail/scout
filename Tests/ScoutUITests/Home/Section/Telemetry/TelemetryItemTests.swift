//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import ScoutUI

struct TelemetryItemTests {
    @Test("The sample carries six items in the mock order")
    func sample() {
        let items = TelemetryItem.sample

        #expect(
            items.map(\.kind.title) == ["Events", "Crashes", "Metrics", "Hangs", "Network", "Resources"]
        )
        #expect(items.map(\.value) == [48, 3, 140, 6, 212, 2])
        #expect(
            items.map(\.caption)
                == ["41 yesterday", "2 groups", "5 kinds", "max 8.2 s", "p99 840 ms", "in 365 days"]
        )
    }

    @Test("Every item reads its value with grouping")
    func values() {
        #expect(TelemetryItem.sample.map(\.valueLabel) == ["48", "3", "140", "6", "212", "2"])
    }
}
