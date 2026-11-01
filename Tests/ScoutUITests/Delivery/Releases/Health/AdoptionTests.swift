//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import ScoutUI

@Suite("Adoption")
struct AdoptionTests {
    @Test("The formatted value rounds to whole percent")
    func formatted() {
        #expect(Adoption(of: 1, in: 4).formatted == "25%")
        #expect(Adoption(of: 0, in: 5).formatted == "0%")
        #expect(Adoption(0.9999).formatted == "100%")
    }

    @Test("A third rounds up to the nearest percent")
    func roundsUp() {
        #expect(Adoption(of: 2, in: 3).formatted == "67%")
    }

    @Test("A zero total gives a zero ratio")
    func zeroTotal() {
        #expect(Adoption(of: 3, in: 0).value == 0)
        #expect(Adoption(of: 0, in: 0).formatted == "0%")
    }

    @Test("A ratio formats with the requested fraction digits")
    func percentage() {
        #expect(Adoption(0.625).percentage(fractionDigits: 1) == "62.5%")
        #expect(Adoption(0.62).percentage(fractionDigits: 0) == "62%")
        #expect(Adoption(0.0).percentage(fractionDigits: 2) == "0.00%")
    }
}
