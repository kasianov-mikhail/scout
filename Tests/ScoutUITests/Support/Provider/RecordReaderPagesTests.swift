//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import ConnectorSupport
@testable import Scout
@testable import ScoutUI

struct RecordReaderPagesTests {
    @Test("readAll follows every cursor and keeps the page order")
    func readAllFollowsCursors() async throws {
        let records = (0..<5).map { Record(recordType: "Event", recordID: "\($0)") }

        let read = try await PagedReader(records: records).readAll(matching: RecordQuery(recordType: Event.self), fields: nil)

        #expect(read.map(\.recordID) == ["0", "1", "2", "3", "4"])
    }
}

private struct PagedReader: RecordReader {
    let records: [Record]

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        RecordChunk(page: records, limit: 2)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }
}
