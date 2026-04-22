//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

struct PeriodCellTests {
    // MARK: - Key Generation

    @Test("Key encodes period and day")
    func keyGeneration() {
        let cell = PeriodCell<Int>(period: .daily, day: 0, value: 5)
        #expect(cell.key == "cell_d_01")
    }

    @Test("Key uses leading zero for single-digit days")
    func keyLeadingZero() {
        let cell = PeriodCell<Int>(period: .weekly, day: 8, value: 1)
        #expect(cell.key == "cell_w_09")
    }

    @Test("Key encodes monthly period")
    func keyMonthly() {
        let cell = PeriodCell<Int>(period: .monthly, day: 11, value: 1)
        #expect(cell.key == "cell_m_12")
    }

    // MARK: - Key Parsing

    @Test("Init from key parses correctly")
    func initFromKey() {
        let cell = PeriodCell<Int>(key: "cell_d_05", value: 10)
        #expect(cell.period == .daily)
        #expect(cell.day == 4)
        #expect(cell.value == 10)
    }

    @Test("Init from key parses weekly")
    func initFromKeyWeekly() {
        let cell = PeriodCell<Int>(key: "cell_w_01", value: 3)
        #expect(cell.period == .weekly)
        #expect(cell.day == 0)
        #expect(cell.value == 3)
    }

    // MARK: - Round-trip

    @Test("Key round-trips through init")
    func keyRoundTrip() {
        let original = PeriodCell<Int>(period: .monthly, day: 6, value: 42)
        let restored = PeriodCell<Int>(key: original.key, value: original.value)

        #expect(restored.period == original.period)
        #expect(restored.day == original.day)
        #expect(restored.value == original.value)
    }

    // MARK: - Combining

    @Test("Addition combines values")
    func addition() {
        let a = PeriodCell<Int>(period: .daily, day: 3, value: 10)
        let b = PeriodCell<Int>(period: .daily, day: 3, value: 7)
        let c = a + b

        #expect(c.period == .daily)
        #expect(c.day == 3)
        #expect(c.value == 17)
    }

    @Test("isDuplicate matches same period and day")
    func isDuplicate() {
        let a = PeriodCell<Int>(period: .weekly, day: 2, value: 1)
        let b = PeriodCell<Int>(period: .weekly, day: 2, value: 9)
        #expect(a.isDuplicate(of: b))
    }

    @Test("isDuplicate rejects different period")
    func isDuplicateDifferentPeriod() {
        let a = PeriodCell<Int>(period: .daily, day: 2, value: 1)
        let b = PeriodCell<Int>(period: .weekly, day: 2, value: 1)
        #expect(!a.isDuplicate(of: b))
    }

    @Test("isDuplicate rejects different day")
    func isDuplicateDifferentDay() {
        let a = PeriodCell<Int>(period: .daily, day: 1, value: 1)
        let b = PeriodCell<Int>(period: .daily, day: 2, value: 1)
        #expect(!a.isDuplicate(of: b))
    }
}
