//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Foundation
import Testing

@testable import Scout

@Suite("HTTPRecord coding")
struct HTTPRecordCodingTests {
    @Test("CKRecord round-trips through the wire format")
    func recordRoundTrip() throws {
        let date = Date(timeIntervalSince1970: 1_750_000_000)

        let record = CKRecord(
            recordType: "Event",
            recordID: CKRecord.ID(recordName: "record-1")
        )
        record["name"] = "login"
        record["param_count"] = Int64(2)
        record["value"] = 1.5
        record["date"] = date
        record["params"] = Data([1, 2, 3])

        let wire = HTTPRecord(record: record)
        let data = try JSONEncoder().encode(wire)
        let restored = try JSONDecoder().decode(HTTPRecord.self, from: data).toRecord

        #expect(restored.recordType == "Event")
        #expect(restored.recordID.recordName == "record-1")
        #expect(restored["name"] == "login")
        #expect(restored["param_count"] == Int64(2))
        #expect(restored["value"] == 1.5)
        #expect(restored["date"] == date)
        #expect(restored["params"] == Data([1, 2, 3]))
    }

    @Test("Integer and floating-point numbers keep their type")
    func numberTypes() throws {
        #expect(HTTPFieldValue(recordValue: Int64(7)) == .int(7))
        #expect(HTTPFieldValue(recordValue: 7 as Int) == .int(7))
        #expect(HTTPFieldValue(recordValue: 7.5) == .double(7.5))
        #expect(HTTPFieldValue(recordValue: 7.0) == .double(7))
    }

    @Test("Dates survive encoding with millisecond precision")
    func datePrecision() throws {
        let value = HTTPFieldValue.date(Date(timeIntervalSince1970: 1_750_000_000.123))
        let data = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(HTTPFieldValue.self, from: data)

        let original = try #require(value.dateValue?.timeIntervalSince1970)
        let restored = try #require(decoded.dateValue?.timeIntervalSince1970)
        #expect(abs(original - restored) < 0.001)
    }
}

extension HTTPFieldValue {
    fileprivate var dateValue: Date? {
        if case .date(let date) = self { return date }
        return nil
    }
}
