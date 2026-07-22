//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Incident where Self: RecordDecodable {
    static func query(filters extra: [RecordQuery.Filter] = []) -> RecordQuery {
        RecordQuery(
            recordType: Self.self,
            filters: Calendar.utc.defaultRange.dateFilters + extra,
            sort: [RecordQuery.Sort(field: "date", ascending: false)]
        )
    }
}
