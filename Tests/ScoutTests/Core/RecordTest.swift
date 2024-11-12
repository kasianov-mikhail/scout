//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Testing

@testable import Scout

@Test("Merge record values") func testMergeRecordValues() async throws {
    let record = CKRecord(recordType: "Test")
    record["foo"] = 10
    record.merge(with: ["foo": 1, "bar": 2])

    #expect(record["foo"] == 11)
    #expect(record["bar"] == 2)
}
