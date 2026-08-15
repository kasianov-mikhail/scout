//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

extension RecordQuery {
    package struct Filter: Codable, Equatable, Sendable {
        package enum Operator: String, Codable, Sendable {
            case equals
            case notEquals
            case greaterThan
            case greaterThanOrEquals
            case lessThan
            case lessThanOrEquals
            case `in`
            case beginsWith
        }

        package let field: String
        package let op: Operator
        package let value: RecordValue

        package init(field: String, op: Operator, value: RecordValue) {
            self.field = field
            self.op = op
            self.value = value
        }
    }
}

extension RecordQuery.Filter {
    func matches(_ fields: [String: RecordValue]) -> Bool {
        guard let value = fields[field] else {
            return false
        }

        switch op {
        case .equals:
            return value == self.value

        case .notEquals:
            return value != self.value

        case .in:
            guard case .strings(let options) = self.value else {
                return false
            }
            return match(value, using: options.contains)

        case .beginsWith:
            guard case .string(let prefix) = self.value else {
                return false
            }
            return match(value) { $0.hasPrefix(prefix) }

        case .greaterThan:
            return compare(value, using: >)

        case .greaterThanOrEquals:
            return compare(value, using: >=)

        case .lessThan:
            return compare(value, using: <)

        case .lessThanOrEquals:
            return compare(value, using: <=)
        }
    }

    private func match(_ value: RecordValue, using isMatch: (String) -> Bool) -> Bool {
        guard case .string(let actual) = value else {
            return false
        }
        return isMatch(actual)
    }

    private func compare(_ value: RecordValue, using areInIncreasingOrder: (Double, Double) -> Bool) -> Bool {
        guard let lhs = value.value, let rhs = self.value.value else {
            return false
        }
        return areInIncreasingOrder(lhs, rhs)
    }
}
