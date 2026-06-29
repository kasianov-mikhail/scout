//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

struct ReleaseVersionTests {
    @Test("Versions compare their components numerically") func testOrdering() {
        #expect(ReleaseVersion(version: "3.9") < ReleaseVersion(version: "3.10"))
        #expect(ReleaseVersion(version: "4.0") < ReleaseVersion(version: "4.0.1"))
        #expect(ReleaseVersion(version: "9.9.9") < ReleaseVersion(version: "10.0"))
    }

    @Test("Equal numeric components fall back to lexicographic order") func testTiebreak() {
        #expect(ReleaseVersion(version: "4.0") < ReleaseVersion(version: "4.0.0"))
        #expect((ReleaseVersion(version: "4.0.0") < ReleaseVersion(version: "4.0")) == false)
    }
}
