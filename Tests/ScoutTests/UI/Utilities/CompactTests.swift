//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct CompactTests {
    @Test("Values below a thousand are unchanged") func belowThousand() {
        #expect(0.compact == "0")
        #expect(42.compact == "42")
        #expect(999.compact == "999")
    }

    @Test("Thousands use the K suffix") func thousands() {
        #expect(1_000.compact == "1.0K")
        #expect(1_500.compact == "1.5K")
        #expect(48_210.compact == "48.2K")
        #expect(999_949.compact == "999.9K")
    }

    @Test("Millions use the M suffix") func millions() {
        #expect(1_000_000.compact == "1.0M")
        #expect(2_500_000.compact == "2.5M")
        #expect(999_949_999.compact == "999.9M")
    }

    @Test("Billions use the B suffix") func billions() {
        #expect(1_000_000_000.compact == "1.0B")
        #expect(2_500_000_000.compact == "2.5B")
    }

    @Test("Rounding rolls up to the next unit instead of overflowing") func rounding() {
        #expect(999_999.compact == "1.0M")
        #expect(999_999_999.compact == "1.0B")
    }
}
