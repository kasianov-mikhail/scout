//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

@Suite("DeviceUsage")
struct DeviceUsageTests {
    @Test("Counts sessions by weekday and hour in UTC")
    func countsSessions() {
        let sundayEvening = DateComponents(
            calendar: .utc, year: 2026, month: 1, day: 4, hour: 19, minute: 30
        ).date!
        let mondayMorning = DateComponents(
            calendar: .utc, year: 2026, month: 1, day: 5, hour: 9, minute: 15
        ).date!

        let usage = DeviceUsage(sessions: [
            Session(startDate: sundayEvening, endDate: nil, id: "1", sessionID: nil, launchID: nil, installID: nil),
            Session(startDate: sundayEvening, endDate: nil, id: "2", sessionID: nil, launchID: nil, installID: nil),
            Session(startDate: mondayMorning, endDate: nil, id: "3", sessionID: nil, launchID: nil, installID: nil),
        ])

        #expect(usage.counts[0][19] == 2)
        #expect(usage.counts[1][9] == 1)
        #expect(usage.maxCount == 2)
        #expect(usage.busiestWindow == "19:00–22:00")
    }

    @Test("No sessions yields no busiest window")
    func emptyUsage() {
        let usage = DeviceUsage(sessions: [])

        #expect(usage.maxCount == 0)
        #expect(usage.busiestWindow == nil)
    }

    @Test("A window wraps around midnight")
    func wrappingWindow() {
        let late = DateComponents(
            calendar: .utc, year: 2026, month: 1, day: 4, hour: 23, minute: 30
        ).date!
        let early = DateComponents(
            calendar: .utc, year: 2026, month: 1, day: 5, hour: 0, minute: 30
        ).date!
        let afterMidnight = DateComponents(
            calendar: .utc, year: 2026, month: 1, day: 5, hour: 1, minute: 30
        ).date!

        let usage = DeviceUsage(sessions: [
            Session(startDate: late, endDate: nil, id: "1", sessionID: nil, launchID: nil, installID: nil),
            Session(startDate: early, endDate: nil, id: "2", sessionID: nil, launchID: nil, installID: nil),
            Session(startDate: afterMidnight, endDate: nil, id: "3", sessionID: nil, launchID: nil, installID: nil),
        ])

        #expect(usage.busiestWindow == "23:00–02:00")
    }
}
