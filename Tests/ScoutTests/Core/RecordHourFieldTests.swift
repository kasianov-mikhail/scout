//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Testing

@testable import Scout

struct RecordHourFieldTests {

    @Test("hourField") func testHourField() throws {
        let calendar = Calendar.UTC
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 1
        components.hour = 12
        let date = calendar.date(from: components)!

        let record = CKRecord(recordType: "Test")
        record["hour"] = date

        #expect(record.hourField == "cell_4_12")
    }
}
