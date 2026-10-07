//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorSupport
import Foundation
import Scout

extension DemoDatabase: RecordReader {
    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        guard let record = records.first(where: { $0.recordID == recordName }) else {
            throw RecordNotFoundError()
        }
        return record
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        RecordChunk(page: records.matching(query), limit: limit)
    }
}
