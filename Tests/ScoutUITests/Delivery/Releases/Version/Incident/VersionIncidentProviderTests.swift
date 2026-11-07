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
@testable import Support

@MainActor
struct VersionIncidentProviderTests {
    private let date = Date().addingTimeInterval(-3600)

    @Test("Fetches only crashes recorded for the requested version")
    func fetchFiltersCrashesByVersion() async throws {
        let database = DatabaseStub()
        database.add(
            crashRecord(appVersion: "2.0"),
            crashRecord(appVersion: "2.0"),
            crashRecord(appVersion: "1.0")
        )

        let provider = VersionIncidentProvider<Crash>(version: "2.0")
        await provider.fetchLatest(in: database)
        let crashes = try #require(provider.records)

        #expect(crashes.count == 2)
    }

    @Test("Ignores crashes without a version")
    func fetchIgnoresCrashesMissingVersion() async throws {
        let database = DatabaseStub()
        database.add(crashRecord(appVersion: nil))

        let provider = VersionIncidentProvider<Crash>(version: "2.0")
        await provider.fetchLatest(in: database)

        #expect(provider.records?.isEmpty == true)
    }

    @Test("Fetches only hangs recorded for the requested version")
    func fetchFiltersHangsByVersion() async throws {
        let database = DatabaseStub()
        database.add(
            hangRecord(appVersion: "2.0"),
            hangRecord(appVersion: "2.0"),
            hangRecord(appVersion: "1.0")
        )

        let provider = VersionIncidentProvider<Hang>(version: "2.0")
        await provider.fetchLatest(in: database)
        let hangs = try #require(provider.records)

        #expect(hangs.count == 2)
    }

    @Test("Ignores hangs without a version")
    func fetchIgnoresHangsMissingVersion() async throws {
        let database = DatabaseStub()
        database.add(hangRecord(appVersion: nil))

        let provider = VersionIncidentProvider<Hang>(version: "2.0")
        await provider.fetchLatest(in: database)

        #expect(provider.records?.isEmpty == true)
    }

    @Test("Reads one page of the version and the next page on demand")
    func fetchReadsOnePage() async throws {
        let database = DatabaseStub()
        for _ in 0...defaultRecordPageSize {
            database.add(crashRecord(appVersion: "2.0"))
        }

        let provider = VersionIncidentProvider<Crash>(version: "2.0")
        await provider.fetchLatest(in: database)

        #expect(provider.records?.count == defaultRecordPageSize)
        #expect(database.readCount(of: Crash.recordType) == 1)

        let cursor = try #require(provider.cursor)
        await provider.fetchMore(cursor: cursor, in: database)

        #expect(provider.records?.count == defaultRecordPageSize + 1)
        #expect(provider.cursor == nil)
    }

    @Test("Refresh reads only the first page")
    func fetchAgainReadsOnePage() async throws {
        let database = DatabaseStub()
        for _ in 0...defaultRecordPageSize {
            database.add(crashRecord(appVersion: "2.0"))
        }

        let provider = VersionIncidentProvider<Crash>(version: "2.0")
        await provider.fetchAgain(in: database)

        #expect(provider.records?.count == defaultRecordPageSize)
        #expect(provider.cursor != nil)
        #expect(database.readCount(of: Crash.recordType) == 1)
    }

    @Test("Hangs with different stacks stay in separate groups")
    func hangsGroupByStack() async throws {
        let database = DatabaseStub()
        database.add(
            hangRecord(appVersion: "2.0", stackTrace: ["main", "draw"]),
            hangRecord(appVersion: "2.0", stackTrace: ["main", "layout"])
        )

        let provider = VersionIncidentProvider<Hang>(version: "2.0")
        await provider.fetchLatest(in: database)
        let hangs = try #require(provider.records)

        #expect(IncidentGroup.groups(from: hangs).count == 2)
    }

    private func crashRecord(appVersion: String?) -> Record {
        var record = Crash.stub(name: "SIGSEGV", sessionID: UUID(), date: date).record
        record["app_version"] = appVersion
        return record
    }

    private func hangRecord(appVersion: String?, stackTrace: [String] = []) -> Record {
        var record = Hang.stub(name: "Main Thread Blocked", stackTrace: stackTrace, sessionID: UUID(), date: date).record
        record["app_version"] = appVersion
        return record
    }
}
