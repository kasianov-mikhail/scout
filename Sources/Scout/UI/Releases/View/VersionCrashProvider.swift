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
    @Published var message: Message?

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
        do {
            let query = RecordQuery(
                recordType: Crash.self,
                filters: Calendar.utc.defaultRange.dateFilters + [
                    RecordQuery.Filter(field: "app_version", op: .equals, value: .string(version))
                ]
            )

            crashes = try await database.readAll(
                matching: query,
                fields: Crash.desiredKeys
            )
        } catch {
            message = Message(error.localizedDescription, level: .error)
        }
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
