//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

@MainActor
class VersionCrashProvider: ObservableObject {
    @Published var crashes: [Crash]?

    let version: String

    init(version: String, crashes: [Crash]? = nil) {
        self.version = version
        self.crashes = crashes
    }

    func fetchIfNeeded(in database: DatabaseReader) async {
        if crashes == nil {
            await fetch(in: database)
        }
    }

    func fetch(in database: DatabaseReader) async {
        let range = Calendar.utc.defaultRange

        do {
            async let crashes: [Crash] = database.readAll(
                matching: RecordQuery(recordType: Crash.self, filters: range.dateFilters),
                fields: Crash.desiredKeys
            )
            async let versions: [Version] = database.readAll(
                matching: RecordQuery(recordType: Version.self, filters: range.dateFilters),
                fields: Version.desiredKeys
            )

            let versionIndex = versionIndex(of: try await versions)
            self.crashes = try await crashes.filter { crash in
                crash.launchID.flatMap { versionIndex[$0] } == version
            }
        } catch {
            crashes = []
        }
    }

    private func versionIndex(of versions: [Version]) -> [UUID: String] {
        Dictionary(
            versions.compactMap { version in
                guard let launchID = version.launchID, let appVersion = version.appVersion else {
                    return nil
                }
                return (launchID, appVersion)
            },
            uniquingKeysWith: { first, _ in first }
        )
    }
}

extension VersionCrashProvider {
    static func fixture() -> VersionCrashProvider {
        VersionCrashProvider(version: "3.2.0", crashes: .samples)
    }
}

extension [Crash] {
    fileprivate static var samples: [Crash] {
        let counts: KeyValuePairs<String, Int> = ["NSRangeException": 8, "Fatal error": 4, "SIGSEGV": 2]

        var crashes: [Crash] = []
        var index = 0

        for (name, count) in counts {
            for _ in 0..<count {
                let date = Date(timeIntervalSinceNow: -Double(index % 13) * 86_400 - Double(index) * 600)
                crashes.append(.sample(name, at: date, sessionID: UUID()))
                index += 1
            }
        }

        return crashes
    }
}
