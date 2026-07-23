//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class VersionIncidentProvider<Element: RecordDecodable & Incident>: FeedProvider<Element>, Periodic {
    let version: String

    init(version: String, records: [Element]? = nil) {
        self.version = version
        super.init()
        self.records = records
    }

    private var query: RecordQuery {
        Element.query(filters: [
            RecordQuery.Filter(
                field: "app_version",
                op: .equals,
                value:
                    .string(version))
        ])
    }

    @discardableResult
    func fetchLatest(in database: DatabaseReader) async -> Bool {
        await fetchAll(matching: query, in: database)
    }
}
