//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct CalendarUTCTests {
    @Test("Calendar.utc uses ISO 8601 identifier")
    func identifier() {
        #expect(Calendar.utc.identifier == .iso8601)
    }

    @Test("Calendar.utc uses UTC time zone")
    func timeZone() {
        #expect(Calendar.utc.timeZone == TimeZone(identifier: "UTC"))
    }

    @Test("Calendar.utc first weekday is Sunday")
    func firstWeekday() {
        #expect(Calendar.utc.firstWeekday == 1)
    }

    @Test("Calendar.utc returns consistent instances")
    func consistency() {
        let a = Calendar.utc
        let b = Calendar.utc
        #expect(a == b)
    }
}
