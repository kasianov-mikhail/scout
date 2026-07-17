//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import ScoutCore

/// In-memory evaluation of a neutral ``RecordQuery`` against a ``Record`` —
/// the stub counterpart of a backend running the query for real. Mirrors the
/// `AND`-of-comparisons shape Scout builds; a record missing a filtered field
/// never matches, as a backend's comparison would skip it.
///
extension Record {
    func matches(_ query: RecordQuery) -> Bool {
        recordType == query.recordType.recordType && query.filters.allSatisfy(matches)
    }

    private func matches(_ filter: RecordQuery.Filter) -> Bool {
        guard let value = fields[filter.field] else { return false }

        switch filter.op {
        case .equals:
            return value == filter.value
        case .notEquals:
            return value != filter.value
        case .in:
            guard case .strings(let options) = filter.value, case .string(let actual) = value else { return false }
            return options.contains(actual)
        case .beginsWith:
            guard case .string(let prefix) = filter.value, case .string(let actual) = value else { return false }
            return actual.hasPrefix(prefix)
        case .greaterThan, .greaterThanOrEquals, .lessThan, .lessThanOrEquals:
            guard let lhs = value.comparable, let rhs = filter.value.comparable else { return false }
            switch filter.op {
            case .greaterThan:
                return lhs > rhs
            case .greaterThanOrEquals:
                return lhs >= rhs
            case .lessThan:
                return lhs < rhs
            case .lessThanOrEquals:
                return lhs <= rhs
            default:
                return false
            }
        }
    }
}

extension RecordValue {
    /// A scalar projection used to order values for range comparisons.
    fileprivate var comparable: Double? {
        switch self {
        case .int(let value):
            Double(value)
        case .double(let value):
            value
        case .date(let value):
            value.timeIntervalSince1970
        default:
            nil
        }
    }
}
