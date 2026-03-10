//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct ActivityPeriodTests {

    // MARK: - Raw Values

    @Test("Raw values encode correctly")
    func rawValues() {
        #expect(ActivityPeriod.daily.rawValue == "d")
        #expect(ActivityPeriod.weekly.rawValue == "w")
        #expect(ActivityPeriod.monthly.rawValue == "m")
    }

    @Test("Init from raw value")
    func initFromRawValue() {
        #expect(ActivityPeriod(rawValue: "d") == .daily)
        #expect(ActivityPeriod(rawValue: "w") == .weekly)
        #expect(ActivityPeriod(rawValue: "m") == .monthly)
        #expect(ActivityPeriod(rawValue: "x") == nil)
    }

    // MARK: - Titles

    @Test("Titles are human-readable")
    func titles() {
        #expect(ActivityPeriod.daily.title == "Daily")
        #expect(ActivityPeriod.weekly.title == "Weekly")
        #expect(ActivityPeriod.monthly.title == "Monthly")
    }

    // MARK: - Spread Components

    @Test("Daily spread component is day")
    func dailySpread() {
        #expect(ActivityPeriod.daily.spreadComponent == .day)
    }

    @Test("Weekly spread component is weekOfYear")
    func weeklySpread() {
        #expect(ActivityPeriod.weekly.spreadComponent == .weekOfYear)
    }

    @Test("Monthly spread component is month")
    func monthlySpread() {
        #expect(ActivityPeriod.monthly.spreadComponent == .month)
    }

    // MARK: - CaseIterable

    @Test("All cases are present")
    func allCases() {
        #expect(ActivityPeriod.allCases.count == 3)
        #expect(ActivityPeriod.allCases.contains(.daily))
        #expect(ActivityPeriod.allCases.contains(.weekly))
        #expect(ActivityPeriod.allCases.contains(.monthly))
    }
}
