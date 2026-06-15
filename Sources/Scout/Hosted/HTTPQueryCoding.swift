//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// A record query in the server's wire format, the counterpart of a
/// ``RecordQuery``.
///
struct HTTPQuery: Codable, Equatable, Sendable {
    var recordType: String?
    var filters: [HTTPFilter]?
    var sort: [HTTPSort]?
    var limit: Int?
    var fields: [String]?
    var cursor: String?
}

struct HTTPFilter: Codable, Equatable, Sendable {
    let field: String
    let op: RecordFilter.Operator
    let value: RecordValue
}

struct HTTPSort: Codable, Equatable, Sendable {
    let field: String
    let ascending: Bool
}

// MARK: - RecordQuery Translation

extension HTTPQuery {
    init(query: RecordQuery, fields: [String]?, limit: Int?) {
        self.recordType = query.recordType
        self.fields = fields
        self.filters = query.filters.map { HTTPFilter(field: $0.field, op: $0.op, value: $0.value) }

        let sort = query.sort.map { HTTPSort(field: $0.field, ascending: $0.ascending) }
        if !sort.isEmpty {
            self.sort = sort
        }

        if let limit, limit != defaultRecordPageSize {
            self.limit = limit
        }
    }
}

// MARK: - Envelopes

struct HTTPWriteRequest: Codable {
    let records: [HTTPRecord]
}

struct HTTPQueryResponse: Codable {
    let records: [HTTPRecord]
    let cursor: String?
}
