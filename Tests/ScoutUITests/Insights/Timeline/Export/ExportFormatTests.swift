//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import ScoutCore
@testable import ScoutUI

struct ExportFormatTests {
    @Test("Timestamps render as ISO 8601 in UTC")
    func testTimestamp() {
        #expect(ExportFormat.timestamp(TimelineFixture.baseDate) == "2023-11-14T22:13:20Z")
    }

    @Test("Days render as zero-padded year-month-day in UTC")
    func testDay() {
        #expect(ExportFormat.day(TimelineFixture.baseDate) == "2023-11-14")
        #expect(ExportFormat.day(Date(timeIntervalSince1970: 0)) == "1970-01-01")
    }

    @Test("Times render as 24-hour hour and minute in UTC")
    func testTime() {
        #expect(ExportFormat.time(TimelineFixture.baseDate) == "22:13")
        #expect(ExportFormat.time(Date(timeIntervalSince1970: 0)) == "00:00")
    }

    @Test("Minutes combine the day and time")
    func testMinute() {
        #expect(ExportFormat.minute(TimelineFixture.baseDate) == "2023-11-14 22:13")
    }

    @Test("Same-day ranges render the end bound as a bare time")
    func testSameDayRange() {
        #expect(
            ExportFormat.range(from: TimelineFixture.baseDate, to: TimelineFixture.at(360)) == "2023-11-14 22:13–22:19")
    }

    @Test("Multi-day ranges repeat the date in the end bound")
    func testMultiDayRange() {
        #expect(
            ExportFormat.range(from: TimelineFixture.baseDate, to: TimelineFixture.at(.day))
                == "2023-11-14 22:13–2023-11-15 22:13")
    }

    @Test("Open ranges render as their start")
    func testOpenRange() {
        #expect(ExportFormat.range(from: TimelineFixture.baseDate, to: nil) == "2023-11-14 22:13")
    }

    @Test("Short IDs are the first eight characters, lowercased")
    func testShortID() {
        let id = UUID(uuidString: "ABCDEF12-3456-7890-ABCD-EF1234567890")!
        #expect(ExportFormat.shortID(id) == "abcdef12")
    }

    @Test("Counts pluralize their noun")
    func testCounted() {
        #expect(ExportFormat.counted(1, .crash) == "1 crash")
        #expect(ExportFormat.counted(0, .crash) == "0 crashes")
        #expect(ExportFormat.counted(3, .event) == "3 events")
    }
}
