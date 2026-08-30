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

struct RangeDateFormatterTests {
    @Test("Uses the en_US locale and medium date style") func testConfiguration() {
        #expect(rangeDateFormatter.locale == Locale(identifier: "en_US"))
        #expect(rangeDateFormatter.dateStyle == .medium)
    }

    /// The chart domain is built from UTC day boundaries, so the label has to read
    /// them in UTC too — in any other zone it names the day before the bars below it.
    @Test("Reads its dates in UTC, like the chart it labels") func testTimeZone() {
        #expect(rangeDateFormatter.timeZone == Calendar.utc.timeZone)
        #expect(rangeDateFormatter.calendar == .utc)
    }

    @Test("Formats a date in the expected style") func testFormatting() throws {
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        parser.timeZone = Calendar.utc.timeZone
        let date = try #require(parser.date(from: "2024-01-01"))

        #expect(rangeDateFormatter.string(from: date) == "Jan 1, 2024")
    }
}
