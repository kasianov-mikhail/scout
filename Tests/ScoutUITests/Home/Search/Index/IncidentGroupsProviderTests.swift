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

@MainActor
struct IncidentGroupsProviderTests {
    @Test("Groups count every page of crashes, not only the first")
    func groupsEveryPage() async throws {
        let records = (0..<5).map { index in
            var record = Record(recordType: Crash.recordType, recordID: "c-\(index)")
            record["name"] = "NSRangeException"
            record["fingerprint"] = index < 4 ? "range" : "null"
            record["date"] = Date(timeIntervalSince1970: TimeInterval(index))
            return record
        }

        let groups = try await IncidentGroupsProvider<Crash>().fetch(in: PagedReader(records: records))

        #expect(groups.map(\.id).sorted() == ["null", "range"])
        #expect(groups.first { $0.id == "range" }?.count == 4)
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
