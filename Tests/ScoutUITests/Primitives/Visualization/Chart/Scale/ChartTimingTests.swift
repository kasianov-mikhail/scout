//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

struct ChartTimingTests {
    private let utc = Calendar.utc

    @Test("Day bins start at UTC midnight") func dayBinAlignsToUTC() {
        let date = Date(timeIntervalSince1970: 1_752_759_000)  // 2025-07-17 13:30 UTC
        let start = binRange(of: date, unit: .day).lowerBound

        #expect(start == utc.startOfDay(for: date))
        #expect(utc.component(.hour, from: start) == 0)
        #expect(utc.component(.minute, from: start) == 0)
    }

    @Test("Hour bins start at the UTC hour boundary") func hourBinAlignsToUTC() {
        let date = Date(timeIntervalSince1970: 1_752_759_000)  // 2025-07-17 13:30 UTC
        let start = binRange(of: date, unit: .hour).lowerBound

        #expect(utc.component(.hour, from: start) == 13)
        #expect(utc.component(.minute, from: start) == 0)
        #expect(utc.component(.second, from: start) == 0)
    }

    @Test("Day-unit ticks land on UTC midnights") func dayTicksAlignToUTC() {
        let base = Date(timeIntervalSince1970: 1_752_759_000)  // 2025-07-17 13:30 UTC
        let points = (0..<7).map { day in
            ChartPoint(date: base.addingTimeInterval(Double(day) * 86400), count: day)
        }
        let extent = ChartExtent(period: Period.week)

        for tick in extent.tickDates(for: points) {
            #expect(utc.component(.hour, from: tick) == 0)
            #expect(utc.component(.minute, from: tick) == 0)
        }
    }
}
