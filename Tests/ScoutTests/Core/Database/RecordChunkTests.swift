//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Testing

@testable import Scout

struct RecordChunkTests {
    @Test("Addition concatenates records")
    func addition() {
        let r1 = CKRecord(recordType: "A")
        let r2 = CKRecord(recordType: "B")
        let r3 = CKRecord(recordType: "C")

        let a = RecordChunk(records: [r1], cursor: nil)
        let b = RecordChunk(records: [r2, r3], cursor: nil)
        let c = a + b

        #expect(c.records.count == 3)
        #expect(c.records[0].recordType == "A")
        #expect(c.records[1].recordType == "B")
        #expect(c.records[2].recordType == "C")
    }

    @Test("Addition takes cursor from right-hand side")
    func additionCursor() {
        let a = RecordChunk(records: [], cursor: nil)
        let b = RecordChunk(records: [], cursor: nil)
        let c = a + b

        #expect(c.cursor == nil)
    }

    @Test("Plus-equals mutates in place")
    func plusEquals() {
        let r1 = CKRecord(recordType: "X")
        let r2 = CKRecord(recordType: "Y")

        var chunk = RecordChunk(records: [r1], cursor: nil)
        chunk += RecordChunk(records: [r2], cursor: nil)

        #expect(chunk.records.count == 2)
        #expect(chunk.records[0].recordType == "X")
        #expect(chunk.records[1].recordType == "Y")
    }
}
