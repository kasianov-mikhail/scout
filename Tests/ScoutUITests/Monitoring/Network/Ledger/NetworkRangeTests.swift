//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import ScoutUI
@testable import Support

@Suite("NetworkRange")
struct NetworkRangeTests {
    let now = Date(year: 2026, month: 10, day: 25, hour: 17, minute: 30)

    @Test("Ranges end today and start the requested number of days ago")
    func trailingRanges() {
        let today = now.startOfDay
        let tomorrow = today.addingDay()

        #expect(NetworkRange.today.range(now: now) == today..<tomorrow)
        #expect(NetworkRange.yesterday.range(now: now) == today.addingDay(-1)..<today)
        #expect(NetworkRange.week.range(now: now) == today.addingDay(-6)..<tomorrow)
        #expect(NetworkRange.month.range(now: now) == today.addingDay(-29)..<tomorrow)
        #expect(NetworkRange.year.range(now: now) == today.addingDay(-364)..<tomorrow)
    }

    @Test("Points use hours for days and days for longer ranges")
    func components() {
        #expect(NetworkRange.today.pointComponent == .hour)
        #expect(NetworkRange.yesterday.pointComponent == .hour)
        #expect(NetworkRange.week.pointComponent == .day)
        #expect(NetworkRange.month.pointComponent == .day)
        #expect(NetworkRange.year.pointComponent == .month)
    }
}
