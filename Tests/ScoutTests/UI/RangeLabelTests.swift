//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct RangeLabelTests {
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    @Test("Single day range") func testSingleDayRange() {
        let startDate = formatter.date(from: "2024-01-01")!
        let endDate = formatter.date(from: "2024-01-02")!
        let range = startDate..<endDate
        let label = range.label(using: formatter)

        #expect(label == "2024-01-01")
    }

    @Test("Multiple days range") func testMultipleDaysRange() {
        let startDate = formatter.date(from: "2024-01-01")!
        let endDate = formatter.date(from: "2024-01-04")!
        let range = startDate..<endDate
        let label = range.label(using: formatter)

        #expect(label == "2024-01-01 – 2024-01-03")
    }
}
