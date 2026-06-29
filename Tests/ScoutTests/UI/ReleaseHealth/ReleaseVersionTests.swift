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
        #expect(ReleaseVersion("3.9") < ReleaseVersion("3.10"))
        #expect(ReleaseVersion("4.0") < ReleaseVersion("4.0.1"))
        #expect(ReleaseVersion("9.9.9") < ReleaseVersion("10.0"))
    }

    @Test("Equal numeric components fall back to lexicographic order") func testTiebreak() {
        #expect(ReleaseVersion("4.0") < ReleaseVersion("4.0.0"))
        #expect((ReleaseVersion("4.0.0") < ReleaseVersion("4.0")) == false)
    }
}
