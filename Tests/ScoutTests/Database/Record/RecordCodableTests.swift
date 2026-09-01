//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct RecordCodableTests {
    @Test("Records round-trip through JSON with every field kind")
    func roundTrip() throws {
        var record = Record(recordType: "Event", recordID: "event-1", metadata: Data([1, 2, 3]))
        record.fields["name"] = .string("login")
        record.fields["count"] = .int(5)
        record.fields["ratio"] = .double(0.5)
        record.fields["date"] = .date(Date(timeIntervalSince1970: 1_000))
        record.fields["blob"] = .bytes(Data([9]))
        record.fields["tags"] = .strings(["a", "b"])

        let data = try JSONEncoder().encode(record)
        let decoded = try JSONDecoder().decode(Record.self, from: data)

        #expect(decoded == record)
    }

    @Test("Records keep the on-disk layout the cache was written with")
    func layout() throws {
        var record = Record(recordType: "Event", recordID: "event-1")
        record.fields["name"] = .string("login")

        let data = try JSONEncoder().encode(record)
        let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(Set(object.keys) == ["recordType", "recordID", "fields"])
        #expect((object["fields"] as? [String: Any])?.keys.contains("name") == true)
    }
}
