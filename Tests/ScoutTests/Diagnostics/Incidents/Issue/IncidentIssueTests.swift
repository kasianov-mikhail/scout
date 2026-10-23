//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("IncidentIssue")
struct IncidentIssueTests {
    @Test("A record round-trips with its status and resolved version")
    func roundTrip() throws {
        let original = IncidentIssue(
            fingerprint: "fp",
            kind: .hang,
            status: .resolved,
            resolvedVersion: "2.4",
            date: Date(timeIntervalSince1970: 1_750_000_000),
            id: "hang-fp"
        )

        let decoded = try IncidentIssue(record: original.record)

        #expect(decoded == original)
    }

    @Test("A record with an unknown status does not decode")
    func unknownStatus() {
        var record = makeRecord()
        record["status"] = "muted"

        #expect(throws: (any Error).self) {
            try IncidentIssue(record: record)
        }
    }

    @Test("A record without a fingerprint does not decode")
    func missingFingerprint() {
        var record = makeRecord()
        record.fields["fingerprint"] = nil

        #expect(throws: (any Error).self) {
            try IncidentIssue(record: record)
        }
    }

    private func makeRecord() -> Record {
        var record = Record(recordType: IncidentIssue.recordType, recordID: "crash-fp")
        record["fingerprint"] = "fp"
        record["category"] = "crash"
        record["status"] = "open"
        record["date"] = Date()
        return record
    }
}
