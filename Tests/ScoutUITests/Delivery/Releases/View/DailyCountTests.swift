//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ScoutCore
@testable import ScoutTestSupport
@testable import ScoutUI

struct DailyCountTests {
    private let calendar = Calendar.current

    @Test("Records bucket into per-day counts across the window") func testDailyBuckets() {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let crashes = [
            Crash.stub(date: today.addingTimeInterval(3600)),
            Crash.stub(date: today.addingTimeInterval(7200)),
            Crash.stub(date: yesterday.addingTimeInterval(60)),
        ]

        let series = DailyCount.series(from: crashes, days: 14, calendar: calendar, endingOn: today)

        #expect(series.count == 14)
        #expect(series.last?.date == today)
        #expect(series.last?.count == 2)
        #expect(series[12].count == 1)
        #expect(series.dropLast(2).allSatisfy { $0.count == 0 })
    }

    @Test("Records outside the window and nil dates are ignored") func testOutOfWindow() {
        let today = calendar.startOfDay(for: Date())
        let old = calendar.date(byAdding: .day, value: -30, to: today)!

        let series = DailyCount.series(
            from: [Crash.stub(date: old), Crash.stub(date: nil)],
            days: 14,
            calendar: calendar,
            endingOn: today
        )

        #expect(series.count == 14)
        #expect(series.allSatisfy { $0.count == 0 })
    }
}
