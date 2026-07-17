//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DateRangeSelection {
    private(set) var start: Date?
    private(set) var end: Date?

    var range: Range<Date>? {
        guard let start else {
            return nil
        }
        return start..<(end ?? start).addingDay()
    }

    func contains(_ date: Date) -> Bool {
        guard let start, let end else {
            return false
        }
        return date >= start && date <= end
    }

    func isEndpoint(_ date: Date) -> Bool {
        date == start || date == end
    }

    mutating func select(_ date: Date) {
        if start == nil || end != nil {
            start = date
            end = nil
        } else if let current = start, date < current {
            start = date
        } else {
            end = date
        }
    }
}
