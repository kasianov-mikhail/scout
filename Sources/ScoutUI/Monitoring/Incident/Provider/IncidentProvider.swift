//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class IncidentProvider<Element: RecordDecodable & Incident>: FeedProvider<Element> {
    var groups: [IncidentGroup<Element>]? {
        records.map(IncidentGroup.groups)
    }

    @discardableResult
    func fetchLatest(in database: DatabaseReader) async -> Bool {
        await fetchLatest(matching: Element.query(), in: database)
    }
}
