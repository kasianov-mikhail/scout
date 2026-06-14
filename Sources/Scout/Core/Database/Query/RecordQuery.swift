//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A backend-neutral query — the counterpart of `CKQuery`.
///
/// Callers describe a query as a record type plus a flat list of `AND`-ed
/// comparisons and a sort order, and each backend translates it into its own
/// dialect: CloudKit into an `NSPredicate`, a Scout server into wire filters.
///
struct RecordQuery: Equatable, Sendable {
    var recordType: String
    var filters: [RecordFilter]
    var sort: [RecordSort]

    init(recordType: String, filters: [RecordFilter] = [], sort: [RecordSort] = []) {
        self.recordType = recordType
        self.filters = filters
        self.sort = sort
    }
}

/// A single `field op value` comparison within a ``RecordQuery``.
struct RecordFilter: Equatable, Sendable {
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

/// A sort key within a ``RecordQuery``.
struct RecordSort: Equatable, Sendable {
    let field: String
    let ascending: Bool
}
