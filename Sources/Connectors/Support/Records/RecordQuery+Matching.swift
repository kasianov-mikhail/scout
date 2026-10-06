//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension [Record] {
    package func matching(_ query: RecordQuery) -> [Record] {
        filter(query.matches).sorted(by: query.ordering)
    }
}

extension RecordQuery {
    fileprivate func matches(_ record: Record) -> Bool {
        record.recordType == recordType.recordType && filters.allSatisfy { $0.matches(record.fields) }
    }

    fileprivate var ordering: (Record, Record) -> Bool {
        { lhs, rhs in
            for key in effectiveSort {
                let order = RecordValue.compare(lhs.fields[key.field], rhs.fields[key.field])
                guard order != .orderedSame else {
                    continue
                }
                return key.ascending ? order == .orderedAscending : order == .orderedDescending
            }
            return false
        }
    }
}

extension RecordValue {
    fileprivate static func compare(_ lhs: RecordValue?, _ rhs: RecordValue?) -> ComparisonResult {
        switch (lhs, rhs) {
        case (nil, nil):
            return .orderedSame
        case (nil, _):
            return .orderedAscending
        case (_, nil):
            return .orderedDescending
        case (.string(let lhs), .string(let rhs)):
            return lhs.compared(to: rhs)
        case (let lhs?, let rhs?):
            guard let lhs = lhs.value, let rhs = rhs.value else {
                return .orderedSame
            }
            return lhs.compared(to: rhs)
        }
    }
}

extension Comparable {
    fileprivate func compared(to other: Self) -> ComparisonResult {
        self < other ? .orderedAscending : self == other ? .orderedSame : .orderedDescending
    }
}
