//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Optional where Wrapped == DateInterval {
    func predicate(field: String, equals id: UUID, dateField: String) -> NSPredicate {
        guard let range = self else {
            return NSPredicate(format: "%K == %@", field, id.uuidString)
        }
        return NSPredicate(
            format: "%K == %@ AND %K >= %@ AND %K <= %@",
            field, id.uuidString,
            dateField, range.start as NSDate,
            dateField, range.end as NSDate
        )
    }
}
