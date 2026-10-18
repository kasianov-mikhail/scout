//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

@MainActor
@Suite("BacktraceProvider")
struct BacktraceProviderTests {
    let incidentID = UUID()

    @Test("Reads the backtrace record named after the incident")
    func readsBacktrace() async throws {
        var record = Record(recordType: "Backtrace", recordID: UUID(incidentBacktrace: incidentID).uuidString)
        record["backtrace"] = try JSONEncoder().encode(Backtrace.sample)
        let database = NamedRecordDatabase(record: record)

        let backtrace = try await BacktraceProvider(incidentID: incidentID.uuidString).fetch(in: database)

        #expect(backtrace == .sample)
    }

    @Test("An incident without a backtrace record gives none")
    func missingRecord() async throws {
        let backtrace = try await BacktraceProvider(incidentID: incidentID.uuidString).fetch(in: DatabaseStub())

        #expect(backtrace == nil)
    }

    @Test("An incident id that is not a UUID gives none")
    func malformedID() async throws {
        let backtrace = try await BacktraceProvider(incidentID: "c-1").fetch(in: DatabaseStub())

        #expect(backtrace == nil)
    }
}

private struct NamedRecordDatabase: RecordReader {
    let record: Record

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        guard recordName == record.recordID else {
            throw RecordNotFoundError()
        }
        return record
    }
}
