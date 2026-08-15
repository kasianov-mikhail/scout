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

        return switch op {
        case .equals:
            value == self.value

        case .notEquals:
            value != self.value

        case .in:
            match(value.string, self.value.strings) { $1.contains($0) }

        case .beginsWith:
            match(value.string, self.value.string) { $0.hasPrefix($1) }

        case .greaterThan:
            match(value.value, self.value.value, using: >)

        case .greaterThanOrEquals:
            match(value.value, self.value.value, using: >=)

        case .lessThan:
            match(value.value, self.value.value, using: <)

        case .lessThanOrEquals:
            match(value.value, self.value.value, using: <=)
        }
    }

    private func match<T, U>(_ lhs: T?, _ rhs: U?, using isMatch: (T, U) -> Bool) -> Bool {
        guard let lhs, let rhs else {
            return false
        }
        return isMatch(lhs, rhs)
    }
}
