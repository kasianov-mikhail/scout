//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("Array Grouping by Date")
struct ArrayGroupingTests {
    private struct TestElement {
        let id: Int
        let date: Date?
    }

    @Test("Group by weekday and hour")
    func testGroupedByWeekdayAndHour() {
        // 2025-08-24 10:00 UTC is a Sunday
        let date1 = ISO8601DateFormatter().date(from: "2025-08-24T10:00:00Z")!
        // 2025-08-24 11:00 UTC, same day, different hour
        let date2 = ISO8601DateFormatter().date(from: "2025-08-24T11:00:00Z")!
        // 2025-08-25 10:00 UTC is a Monday
        let date3 = ISO8601DateFormatter().date(from: "2025-08-25T10:00:00Z")!

        let data = [
            TestElement(id: 1, date: date1),
            TestElement(id: 2, date: date2),
            TestElement(id: 3, date: date3),
            TestElement(id: 4, date: nil),
        ]

        let result = data.grouped(by: \.date)

        #expect(result.keys.count == 3)
        #expect(result["cell_1_10"]?.count == 1)
        #expect(result["cell_1_10"]?.first?.id == 1)
        #expect(result["cell_1_11"]?.count == 1)
        #expect(result["cell_1_11"]?.first?.id == 2)
        #expect(result["cell_2_10"]?.count == 1)
        #expect(result["cell_2_10"]?.first?.id == 3)
    }
}
