//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorSupport
import Foundation
import SymbolTable
import Testing

@testable import Scout
@testable import ScoutUI

@MainActor
struct IncidentProviderTests {
    @Test("A crash from the next page joins the symbolicated group of the first page")
    func fetchMoreKeepsSymbolicatedGroup() async throws {
        let app = UUID()
        let newer = Crash.stub(fingerprint: "A", date: Date())
        let older = Crash.stub(fingerprint: "B", date: Date().addingTimeInterval(-3600))
        let database = try PagedIncidentDatabase(crashes: [newer, older], app: app)

        let provider = IncidentProvider<Crash>()
        await provider.fetchLatest(in: database)
        let cursor = try #require(provider.cursor)
        await provider.fetchMore(cursor: cursor, in: database)

        let groups = try #require(provider.groups)
        #expect(groups.count == 1)
        #expect(groups.first?.count == 2)
        #expect(groups.first?.id == "MyApp|handle")
    }
}

private final class PagedIncidentDatabase: DatabaseReader, @unchecked Sendable {
    private let crashes: [Record]
    private let backtraces: [Record]
    private let symbols: Record

    init(crashes: [Crash], app: UUID) throws {
        let backtrace = Backtrace(
            images: [Backtrace.Image(name: "MyApp", uuid: app)],
            threads: [Backtrace.Thread(attributed: true, frames: [Backtrace.Frame(image: 0, offset: 0x10)])]
        )
        let table = SymbolTable(
            uuid: app,
            functions: [SymbolTable.Function(start: 0, end: 0x100, name: "handle")],
            lines: [],
            inlines: []
        )
        self.crashes = crashes.map(\.record)
        self.backtraces = try crashes.map { crash in
            var record = Record(recordType: BacktraceRecord.recordType, recordID: UUID().uuidString)
            record["incident_id"] = crash.id
            record["date"] = crash.date
            record["backtrace"] = try JSONEncoder().encode(backtrace)
            return record
        }
        var symbols = Record(recordType: BundledSymbols.fileType, recordID: UUID(symbolsFile: app).uuidString)
        symbols["file"] = try table.data
        self.symbols = symbols
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        if query.recordType.recordType == BacktraceRecord.recordType {
            return RecordChunk(records: backtraces.matching(query), cursor: nil)
        }
        return RecordChunk(page: crashes, limit: 1)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        guard recordName == symbols.recordID else {
            throw RecordNotFoundError()
        }
        return symbols
    }

    func eventSeries(matching query: EventSeriesQuery) async throws -> [MetricSeries] { [] }
    func lifecycleSeries(matching query: LifecycleSeriesQuery) async throws -> [MetricSeries] { [] }
    func metricSeries(matching query: MetricSeriesQuery) async throws -> [MetricSeries] { [] }
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] { [] }
    func retention(in range: Range<Date>) async throws -> [RetentionCohort] { [] }
    func devices(in range: Range<Date>) async throws -> [DeviceActivity] { [] }
    func deviceCounts(in ranges: [Range<Date>]) async throws -> [Int] { [] }
}
