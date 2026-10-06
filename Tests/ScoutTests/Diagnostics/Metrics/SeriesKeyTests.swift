//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

struct SeriesKeyTests {
    @Test func treatsMissingCategoryAndVersionAsEmpty() {
        #expect(makeKey(category: nil) < makeKey(category: "billing"))
        #expect(makeKey(version: nil) < makeKey(version: "1.0"))
        #expect(makeKey(name: "Crash") < makeKey(name: "Session", category: nil, version: nil))
    }

    private func makeKey(name: String = "Session", category: String? = nil, version: String? = nil) -> SeriesKey {
        SeriesKey(name: name, category: category, version: version)
    }
}
