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

    @Test("Fetches only crashes recorded for the requested version")
    func fetchFiltersByVersion() async throws {
        let database = DatabaseStub()
        database.add(
            crashRecord(appVersion: "2.0"),
            crashRecord(appVersion: "2.0"),
            crashRecord(appVersion: "1.0")
        )

        let provider = VersionCrashProvider(version: "2.0")
        await provider.fetchIfNeeded(in: database)
        let crashes = try #require(provider.crashes)

        #expect(crashes.count == 2)
    }

    @Test("Ignores crashes without a version")
    func fetchIgnoresMissingVersion() async throws {
        let database = DatabaseStub()
        database.add(crashRecord(appVersion: nil))

        let provider = VersionCrashProvider(version: "2.0")
        await provider.fetchIfNeeded(in: database)

        #expect(provider.crashes?.isEmpty == true)
    }

    private func crashRecord(appVersion: String?) -> Record {
        var record = Record(recordType: "Crash", recordID: UUID().uuidString)
        record["name"] = "SIGSEGV"
        record["app_version"] = appVersion
        record["session_id"] = UUID().uuidString
        record["date"] = date
        return record
    }
}
