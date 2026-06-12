//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Range<Date> {
    /// A predicate matching records whose `date` falls within this range.
    var datePredicate: NSPredicate {
        NSPredicate(
            format: "date >= %@ AND date < %@",
            lowerBound as NSDate,
            upperBound as NSDate
        )
    }
}
