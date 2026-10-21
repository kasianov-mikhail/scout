//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

@MainActor
@Suite("Crash threads")
struct CrashThreadsTests {
    @Test("Other threads keep their position and leave out the crashed one")
    func otherRows() {
        let rows = [CrashThread].samples.otherRows

        #expect(rows.map(\.id) == [0, 2])
        #expect(rows.map(\.name) == ["Thread 0", "Thread 2"])
        #expect(rows.map(\.frameCount) == ["2 frames", "1 frame"])
    }

    @Test("The provider reads the threads of a crash record")
    func providerReadsThreads() async throws {
        var record = Record(recordType: Crash.recordType, recordID: "c-1")
        record["threads"] = try JSONEncoder().encode([CrashThread].samples)
        let provider = CrashThreadsProvider(crashID: "c-1")

        let threads = try await provider.fetch(in: LookupDatabase(record: record))

        #expect(threads == .samples)
    }

    @Test("A crash record without threads gives none")
    func providerWithoutThreads() async throws {
        let provider = CrashThreadsProvider(crashID: "c-1")

        let threads = try await provider.fetch(in: LookupDatabase(record: Record(recordType: Crash.recordType, recordID: "c-1")))

        #expect(threads.isEmpty)
    }
}

private struct LookupDatabase: RecordReader {
    let record: Record

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        RecordChunk(records: [], cursor: nil)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        record
    }
}
