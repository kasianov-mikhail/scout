//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct RecordQuery: Sendable {
    package let recordType: any RecordDecodable.Type

    package var filters: [Filter] = []
    package var sort: [Sort] = []

    package init(recordType: any RecordDecodable.Type, filters: [Filter] = [], sort: [Sort] = []) {
        self.recordType = recordType
        self.filters = filters
        self.sort = sort
    }

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

    package struct Sort: Codable, Equatable, Sendable {
        package let field: String
        package let ascending: Bool

        package init(field: String, ascending: Bool) {
            self.field = field
            self.ascending = ascending
        }
    }
}

package protocol RecordDecodable: Sendable, Equatable, RecordEncodable {
    static var desiredKeys: [String] { get }

    init(record: Record) throws
}
