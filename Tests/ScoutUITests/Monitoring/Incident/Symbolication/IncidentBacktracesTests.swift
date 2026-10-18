//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import SymbolTable
import Testing

@testable import Scout
@testable import ScoutUI

@Suite("IncidentBacktraces")
struct IncidentBacktracesTests {
    @Test("Backtraces in a period load with their tables and give group keys by incident")
    func loading() async throws {
        let app = UUID()
        let incident = UUID().uuidString
        let backtrace = Backtrace(
            images: [Backtrace.Image(name: "MyApp", uuid: app)],
            threads: [Backtrace.Thread(attributed: true, frames: [Backtrace.Frame(image: 0, offset: 0x10)])]
        )
        let table = SymbolTable(
            uuid: app,
            functions: [SymbolTable.Function(start: 0, end: 0x100, name: "main")],
            lines: [],
            inlines: []
        )

        var backtraceRecord = Record(recordType: "Backtrace", recordID: UUID().uuidString)
        backtraceRecord["incident_id"] = incident
        backtraceRecord["backtrace"] = try JSONEncoder().encode(backtrace)
        var symbolsRecord = Record(recordType: BundledSymbols.fileType, recordID: UUID(symbolsFile: app).uuidString)
        symbolsRecord["file"] = try table.data

        let database = PeriodDatabase(backtraces: [backtraceRecord], symbols: [symbolsRecord])
        let loaded = try await IncidentBacktraces(range: Date.distantPast..<Date.distantFuture, database: database)

        #expect(loaded.details[incident]?.backtrace == backtrace)
        #expect(loaded.groupKeys == [incident: "MyApp|main"])
    }
}

private struct PeriodDatabase: RecordReader {
    let backtraces: [Record]
    let symbols: [Record]

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        RecordChunk(records: query.recordType.recordType == "Backtrace" ? backtraces : [], cursor: nil)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        guard let record = symbols.first(where: { $0.recordID == recordName }) else {
            throw RecordNotFoundError()
        }
        return record
    }
}
