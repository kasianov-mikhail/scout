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
                matching: query(name: SessionObject.recordType, in: range),
                fields: nil
            )
            async let crashes = database.readAll(
                matching: query(name: CrashObject.recordType, in: range),
                fields: nil
            )
            releases = try await releaseReport(
                sessions: sessions.map(GridMatrix<Int>.init),
                crashes: crashes.map(GridMatrix<Int>.init),
                range: range
            )
        } catch {
            releases = []
        }
    }

    private func query(name: String, in range: Range<Date>) -> RecordQuery {
        RecordQuery(
            recordType: GridMatrix<Int>.self,
            filters: range.dateFilters + [
                RecordQuery.Filter(field: "name", op: .equals, value: .string(name))
            ]
        )
    }
}

extension ReleaseHealthProvider {
    static func fixture() -> ReleaseHealthProvider {
        ReleaseHealthProvider(releases: ReleaseHealth.samples)
    }
}
