//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@MainActor
struct VersionCrashProviderTests {
    private let date = Date().addingTimeInterval(-3600)

    @Test("Fetches only crashes whose launch maps to the requested version")
    func fetchFiltersByVersion() async throws {
        let launchLatest = UUID()
        let launchOld = UUID()

        let database = DatabaseStub()
        database.add(
            versionRecord(appVersion: "2.0", launchID: launchLatest),
            versionRecord(appVersion: "1.0", launchID: launchOld),
            crashRecord(launchID: launchLatest),
            crashRecord(launchID: launchLatest),
            crashRecord(launchID: launchOld)
        )

        let provider = VersionCrashProvider(version: "2.0")
        await provider.fetchIfNeeded(in: database)
        let crashes = try #require(provider.crashes)

        #expect(crashes.count == 2)
    }

    @Test("Ignores crashes on unknown launches")
    func fetchIgnoresUnknownLaunch() async throws {
        let database = DatabaseStub()
        database.add(crashRecord(launchID: UUID()))

        let provider = VersionCrashProvider(version: "2.0")
        await provider.fetchIfNeeded(in: database)

        #expect(provider.crashes?.isEmpty == true)
    }

    private func versionRecord(appVersion: String, launchID: UUID) -> Record {
        var record = Record(recordType: "Version", recordID: UUID().uuidString)
        record["app_version"] = appVersion
        record["launch_id"] = launchID.uuidString
        record["date"] = date
        return record
    }

    private func crashRecord(launchID: UUID) -> Record {
        var record = Record(recordType: "Crash", recordID: UUID().uuidString)
        record["name"] = "SIGSEGV"
        record["launch_id"] = launchID.uuidString
        record["session_id"] = UUID().uuidString
        record["date"] = date
        return record
    }
}
