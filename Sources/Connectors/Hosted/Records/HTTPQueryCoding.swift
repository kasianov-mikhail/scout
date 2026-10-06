//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct HTTPQuery: Codable, Sendable {
    var recordType: String?
    var filters: [RecordQuery.Filter]?
    var sort: [RecordQuery.Sort]?
    var limit: Int?
    var fields: [String]?
    var cursor: String?
}

extension HTTPQuery {
    init(query: RecordQuery, fields: [String]?, limit: Int?) {
        self.recordType = query.recordType.recordType
        self.fields = fields
        self.filters = query.filters
        self.sort = query.effectiveSort

        if let limit, limit != defaultRecordPageSize {
            self.limit = limit
        }
    }
}

struct HTTPWriteRequest: Encodable {
    let records: [HTTPRecord]
}

struct HTTPQueryResponse: Decodable {
    let records: [HTTPRecord]
    let cursor: String?
}
