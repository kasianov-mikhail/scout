//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct RecordQuery: Sendable {
    let recordType: any RecordDecodable.Type

    var filters: [Filter] = []
    var sort: [Sort] = []

    struct Filter: Codable, Equatable, Sendable {
        enum Operator: String, Codable, Sendable {
            case equals
            case notEquals
            case greaterThan
            case greaterThanOrEquals
            case lessThan
            case lessThanOrEquals
            case `in`
            case beginsWith
        }

        let field: String
        let op: Operator
        let value: RecordValue
    }

    struct Sort: Codable, Equatable, Sendable {
        let field: String
        let ascending: Bool
    }
}

protocol RecordDecodable: Sendable, Equatable, RecordEncodable {
    static var desiredKeys: [String] { get }

    init(record: Record) throws
}
