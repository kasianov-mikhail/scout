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
            async let versions = database.readAll(
                matching: RecordQuery(recordType: Version.self, filters: range.dateFilters),
                fields: Version.desiredKeys
            )
            async let crashes = database.readAll(
                matching: RecordQuery(recordType: Crash.self, filters: range.dateFilters),
                fields: Crash.desiredKeys
            )
            async let sessions = database.readAll(
                matching: RecordQuery(recordType: Session.self, filters: range.sessionFilters),
                fields: Session.desiredKeys
            )

            releases = try await ReleaseHealth.build(
                versions: versions.map(Version.init),
                crashes: crashes.map(Crash.init),
                sessions: sessions.map(Session.init),
                range: range
            )
        } catch {
            releases = []
        }
    }
}

extension ReleaseHealthProvider {
    static func fixture() -> ReleaseHealthProvider {
        ReleaseHealthProvider(releases: ReleaseHealth.samples)
    }
}

extension Range<Date> {
    fileprivate var sessionFilters: [RecordQuery.Filter] {
        [
            RecordQuery.Filter(field: "start_date", op: .greaterThanOrEquals, value: .date(lowerBound)),
            RecordQuery.Filter(field: "start_date", op: .lessThan, value: .date(upperBound)),
        ]
    }
}
