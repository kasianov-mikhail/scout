//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension RecordQuery {
    package var primarySort: Sort {
        sort.first ?? Sort(field: dateField, ascending: false)
    }

    package var effectiveSort: [Sort] {
        sort.isEmpty ? [primarySort] : sort
    }

    private var dateField: String {
        switch recordType.recordType {
        case SessionEntry.recordType, LaunchEntry.recordType:
            "start_date"
        default:
            "date"
        }
    }
}
