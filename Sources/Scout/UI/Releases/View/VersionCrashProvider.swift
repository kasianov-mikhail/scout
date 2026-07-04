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
