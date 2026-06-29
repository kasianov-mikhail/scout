//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import SwiftUI

@MainActor
class ReleaseHealthProvider: ObservableObject {
    @Published var releases: [ReleaseHealth]?

    init(releases: [ReleaseHealth]? = nil) {
        self.releases = releases
    }

    func fetchIfNeeded(in database: DatabaseReader) async {
        if releases == nil {
            await fetch(in: database)
        }
    }

    func fetch(in database: DatabaseReader) async {
        let range = Calendar.utc.defaultRange

        do {
            async let sessions = database.readAll(
                matching: sessionQuery,
                fields: nil
            )
            async let crashes = database.readAll(
                matching: RecordQuery(recordType: Crash.self, filters: range.dateFilters),
                fields: Crash.desiredKeys
            )
            async let versions = database.readAll(
                matching: RecordQuery(recordType: Version.self, filters: range.dateFilters),
                fields: Version.desiredKeys
            )

            releases = try await ReleaseReport(
                sessionMatrices: sessions.map(GridMatrix<Int>.init),
                crashes: crashes.map(Crash.init),
                versions: versions.map(Version.init),
                range: range
            ).releases
        } catch {
            releases = []
        }
    }

    private var sessionQuery: RecordQuery {
        let filter = RecordQuery.Filter(
            field: "name",
            op: .equals,
            value: .string(SessionObject.recordType)
        )
        return RecordQuery(
            recordType: GridMatrix<Int>.self,
            filters: Calendar.utc.defaultRange.dateFilters + [filter]
        )
    }
}

extension ReleaseHealthProvider {
    static func fixture() -> ReleaseHealthProvider {
        ReleaseHealthProvider(releases: ReleaseHealth.samples)
    }
}
