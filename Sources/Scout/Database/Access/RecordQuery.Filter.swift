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
            guard case .strings(let options) = self.value, case .string(let actual) = value else {
                return false
            }
            return options.contains(actual)

        case .beginsWith:
            guard case .string(let prefix) = self.value, case .string(let actual) = value else {
                return false
            }
            return actual.hasPrefix(prefix)

        case .greaterThan, .greaterThanOrEquals, .lessThan, .lessThanOrEquals:
            guard let lhs = value.value, let rhs = self.value.value else {
                return false
            }
            switch op {
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
