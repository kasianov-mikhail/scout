//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

struct CellProtocolTests {
    @Test("Single digit gets leading zero")
    func singleDigitLeadingZero() {
        #expect(0.leadingZero == "00")
        #expect(1.leadingZero == "01")
        #expect(9.leadingZero == "09")
    }

    @Test("Double digit stays unchanged")
    func doubleDigitLeadingZero() {
        #expect(10.leadingZero == "10")
        #expect(42.leadingZero == "42")
        #expect(99.leadingZero == "99")
    }

    @Test("Triple digit is not truncated")
    func tripleDigitLeadingZero() {
        #expect(100.leadingZero == "100")
    }
}
