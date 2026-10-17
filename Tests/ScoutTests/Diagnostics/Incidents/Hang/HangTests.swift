//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("Hang")
struct HangTests {
    @Test("Decoding recomputes the fingerprint, ignoring the stored one")
    func decodingRecomputesFingerprint() throws {
        var record = Record(recordType: Hang.recordType, recordID: "h-1")
        record["name"] = "Main Thread Blocked"
        record["reason"] = "Main thread unresponsive for 3.2s"
        record["fingerprint"] = "stale-per-occurrence-fingerprint"
        record["stack_trace"] = try JSONEncoder().encode(["frame0"])

        let hang = try Hang(record: record)

        let expected = CrashFingerprint(name: "Main Thread Blocked", reason: nil, stackTrace: ["frame0"]).value
        #expect(hang.fingerprint == expected)
    }

    @Test("Decoded hangs with the same stack share a fingerprint despite differing reasons")
    func decodedHangsShareFingerprint() throws {
        func makeRecord(id: String, reason: String) throws -> Record {
            var record = Record(recordType: Hang.recordType, recordID: id)
            record["name"] = "Main Thread Blocked"
            record["reason"] = reason
            record["stack_trace"] = try JSONEncoder().encode(["frame0", "frame1"])
            return record
        }

        let first = try Hang(record: makeRecord(id: "h-1", reason: "Main thread unresponsive for 3.2s"))
        let second = try Hang(record: makeRecord(id: "h-2", reason: "Main thread unresponsive for 8.4s"))

        #expect(first.fingerprint == second.fingerprint)
    }
}
