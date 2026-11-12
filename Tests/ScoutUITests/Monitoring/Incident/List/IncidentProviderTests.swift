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

    @Test("A group stays partial until the last page loads")
    func partialUntilLastPage() async throws {
        let crashes = [Crash.stub(fingerprint: "A", date: Date()), Crash.stub(fingerprint: "A", date: Date().addingTimeInterval(-.hour))]
        let database = try PagedIncidentDatabase(crashes: crashes, app: UUID())

        let provider = IncidentProvider<Crash>()
        await provider.fetchLatest(in: database)
        #expect(provider.groups?.first?.isPartial == true)

        let cursor = try #require(provider.cursor)
        await provider.fetchMore(cursor: cursor, in: database)

        let group = try #require(provider.groups?.first)
        #expect(!group.isPartial)
        #expect(group.count == 2)
    }

    @Test("A second fetchLatest looks up the backtrace of the new crash only")
    func fetchLatestLooksUpNewCrashes() async throws {
        let older = Crash.stub(fingerprint: "A", date: Date().addingTimeInterval(-.hour))
        let database = try PagedIncidentDatabase(crashes: [older], app: UUID(), pageSize: 10)

        let provider = IncidentProvider<Crash>()
        await provider.fetchLatest(in: database)

        let newer = Crash.stub(fingerprint: "B", date: Date())
        database.insert(newer, backtrace: true)
        await provider.fetchLatest(in: database)

        #expect(database.backtraceLookups == [[older.backtraceID], [newer.backtraceID]])
        #expect(provider.groups?.count == 1)
        #expect(provider.groups?.first?.count == 2)
    }

    @Test("fetchAgain skips crashes whose backtrace loaded, with or without a key")
    func fetchAgainSkipsResolvedCrashes() async throws {
        let symbolicated = Crash.stub(fingerprint: "A", date: Date())
        let systemOnly = Crash.stub(fingerprint: "B", date: Date().addingTimeInterval(-.hour))
        let corrupted = Crash.stub(fingerprint: "C", date: Date().addingTimeInterval(-2 * .hour))
        let database = try PagedIncidentDatabase(crashes: [symbolicated, systemOnly, corrupted], app: UUID(), pageSize: 10, backtrace: false)
        database.attach(database.payload, to: symbolicated)
        let systemBacktrace = Backtrace(
            images: [Backtrace.Image(name: "libsystem_kernel.dylib", uuid: UUID())],
            threads: [Backtrace.Thread(attributed: true, frames: [Backtrace.Frame(image: 0, offset: 0x10)])]
        )
        database.attach(try JSONEncoder().encode(systemBacktrace), to: systemOnly)
        database.attach(Data("corrupted".utf8), to: corrupted)

        let provider = IncidentProvider<Crash>()
        await provider.fetchAgain(in: database)
        await provider.fetchAgain(in: database)

        #expect(database.backtraceLookups.count == 1)
        #expect(provider.keys.keys.sorted() == [symbolicated.id])
    }

    @Test("A refresh looks up a crash again until its backtrace arrives")
    func fetchAgainRetriesMissingBacktrace() async throws {
        let crash = Crash.stub(fingerprint: "A", date: Date())
        let database = try PagedIncidentDatabase(crashes: [crash], app: UUID(), pageSize: 10, backtrace: false)

        let provider = IncidentProvider<Crash>()
        await provider.fetchAgain(in: database)
        #expect(provider.keys.isEmpty)

        database.attach(database.payload, to: crash)
        await provider.fetchLatest(in: database)
        await provider.fetchAgain(in: database)

        #expect(provider.keys == [crash.id: "MyApp|handle"])
        #expect(database.backtraceLookups == [[crash.backtraceID], [crash.backtraceID]])
    }

    @Test("A refresh does not look up an old crash without a backtrace again")
    func fetchAgainSkipsOldMissingBacktrace() async throws {
        let recent = Crash.stub(fingerprint: "A", date: Date())
        let old = Crash.stub(fingerprint: "B", date: Date().addingTimeInterval(-2 * .day))
        let database = try PagedIncidentDatabase(crashes: [recent, old], app: UUID(), pageSize: 10, backtrace: false)

        let provider = IncidentProvider<Crash>()
        await provider.fetchAgain(in: database)
        await provider.fetchAgain(in: database)

        #expect(database.backtraceLookups == [[recent.backtraceID, old.backtraceID], [recent.backtraceID]])
    }

    @Test("fetchAgain drops the key of a crash that left the feed")
    func fetchAgainDropsRemovedKeys() async throws {
        let kept = Crash.stub(fingerprint: "A", date: Date())
        let removed = Crash.stub(fingerprint: "B", date: Date().addingTimeInterval(-.hour))
        let database = try PagedIncidentDatabase(crashes: [kept, removed], app: UUID(), pageSize: 10)

        let provider = IncidentProvider<Crash>()
        await provider.fetchAgain(in: database)
        #expect(provider.keys.count == 2)

        database.remove(removed)
        await provider.fetchAgain(in: database)

        #expect(provider.keys.keys.sorted() == [kept.id])
        #expect(database.backtraceLookups.count == 1)
    }
}

private final class PagedIncidentDatabase: DatabaseReader, @unchecked Sendable {
    let payload: Data
    private let pageSize: Int
    private var crashes: [Record]
    private var backtraces: [Record]
    private let symbols: Record

    private(set) var backtraceLookups: [[String]] = []

    init(crashes: [Crash], app: UUID, pageSize: Int = 1, backtrace: Bool = true) throws {
        let table = SymbolTable(
            uuid: app,
            functions: [SymbolTable.Function(start: 0, end: 0x100, name: "handle")],
            lines: [],
            inlines: []
        )
        self.payload = try JSONEncoder().encode(
            Backtrace(
                images: [Backtrace.Image(name: "MyApp", uuid: app)],
                threads: [Backtrace.Thread(attributed: true, frames: [Backtrace.Frame(image: 0, offset: 0x10)])]
            )
        )
        self.pageSize = pageSize
        self.crashes = []
        self.backtraces = []
        var symbols = Record(recordType: BundledSymbols.fileType, recordID: UUID(symbolsFile: app).uuidString)
        symbols["uuid"] = symbols.recordID
        symbols["file"] = try table.data
        self.symbols = symbols

        for crash in crashes {
            insert(crash, backtrace: backtrace)
        }
    }

    func insert(_ crash: Crash, backtrace: Bool) {
        crashes.append(crash.record)
        if backtrace {
            attach(payload, to: crash)
        }
    }

    func attach(_ payload: Data, to crash: Crash) {
        var record = Record(recordType: BacktraceRecord.recordType, recordID: crash.backtraceID)
        record["uuid"] = crash.backtraceID
        record["incident_id"] = crash.id
        record["date"] = crash.date
        record["backtrace"] = payload
        backtraces.append(record)
    }

    func remove(_ crash: Crash) {
        crashes.removeAll { $0.recordID == crash.id }
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        if query.recordType.recordType == BacktraceRecord.recordType {
            if case .strings(let values) = query.filters.first?.value {
                backtraceLookups.append(values)
            }
            return RecordChunk(records: backtraces.matching(query), cursor: nil)
        }
        if query.recordType.recordType == BundledSymbols.fileType {
            return RecordChunk(records: [symbols].matching(query), cursor: nil)
        }
        return RecordChunk(page: crashes, limit: pageSize)
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        throw RecordNotFoundError()
    }

    func eventSeries(matching query: EventSeriesQuery) async throws -> [MetricSeries] { [] }
    func lifecycleSeries(matching query: LifecycleSeriesQuery) async throws -> [MetricSeries] { [] }
    func metricSeries(matching query: MetricSeriesQuery) async throws -> [MetricSeries] { [] }
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] { [] }
    func retention(in range: Range<Date>) async throws -> [RetentionCohort] { [] }
    func devices(in range: Range<Date>) async throws -> [DeviceActivity] { [] }
    func deviceCounts(in ranges: [Range<Date>]) async throws -> [Int] { [] }

    func incidentIndex(recordType: String, in range: Range<Date>) async throws -> IncidentIndex? {
        Issue.record("The incident list must not read the index")
        return nil
    }
}

extension Crash {
    fileprivate var backtraceID: String {
        UUID(incidentBacktrace: UUID(uuidString: id)!).uuidString
    }
}
