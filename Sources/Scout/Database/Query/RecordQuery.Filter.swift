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
