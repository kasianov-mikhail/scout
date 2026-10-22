//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import ConnectorSupport
import Foundation
import SymbolTable
import Testing

@testable import Scout
@testable import ScoutUI

@Suite("IncidentBacktraces")
struct IncidentBacktracesTests {
    let app = UUID()

    @Test("Backtraces of the given incidents load with their tables and give group keys by incident")
    func loading() async throws {
        let incident = UUID().uuidString
        let other = UUID().uuidString
        let database = try IncidentDatabase(backtraces: [makeBacktrace(incident: incident), makeBacktrace(incident: other)], symbols: [makeSymbols()])

        let loaded = try await IncidentBacktraces(incidentIDs: [incident], database: database)

        #expect(loaded.details[incident]?.backtrace == backtrace)
        #expect(loaded.groupKeys == [incident: "MyApp|main"])
    }

    @Test("More incidents than one membership filter holds load in several batches")
    func batches() async throws {
        let incidents = (0..<300).map { _ in UUID().uuidString }
        let database = try IncidentDatabase(backtraces: incidents.map(makeBacktrace), symbols: [makeSymbols()])

        let loaded = try await IncidentBacktraces(incidentIDs: incidents, database: database)

        #expect(Set(loaded.details.keys) == Set(incidents))
    }

    @Test("An incident id that is not a UUID loads nothing")
    func malformedID() async throws {
        let database = try IncidentDatabase(backtraces: [], symbols: [])

        let loaded = try await IncidentBacktraces(incidentIDs: ["c-1"], database: database)

        #expect(loaded.details.isEmpty)
    }

    private var backtrace: Backtrace {
        Backtrace(
            images: [Backtrace.Image(name: "MyApp", uuid: app)],
            threads: [Backtrace.Thread(attributed: true, frames: [Backtrace.Frame(image: 0, offset: 0x10)])]
        )
    }

    private func makeBacktrace(incident: String) throws -> Record {
        let id = UUID(incidentBacktrace: try #require(UUID(uuidString: incident))).uuidString
        var record = Record(recordType: "Backtrace", recordID: id)
        record["uuid"] = id
        record["incident_id"] = incident
        record["backtrace"] = try JSONEncoder().encode(backtrace)
        return record
    }

    private func makeSymbols() throws -> Record {
        let table = SymbolTable(
            uuid: app,
            functions: [SymbolTable.Function(start: 0, end: 0x100, name: "main")],
            lines: [],
            inlines: []
        )
        var record = Record(recordType: BundledSymbols.fileType, recordID: UUID(symbolsFile: app).uuidString)
        record["uuid"] = record.recordID
        record["file"] = try table.data
        return record
    }
}

private struct IncidentDatabase: RecordReader {
    let backtraces: [Record]
    let symbols: [Record]

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        for filter in query.filters {
            guard case .strings(let values) = filter.value, values.count <= 250 else {
                throw MembershipLimitError()
            }
        }
        return RecordChunk(records: (backtraces + symbols).matching(query), cursor: nil)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }
}

private struct MembershipLimitError: Error {}
