//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension HTTPDatabase: DatabaseWriter {
    func write(record: Record) async throws {
        try await write(records: [record])
    }

    func write(records: [Record]) async throws {
        for chunk in records.chunked(into: Self.maxBatchSize) {
            let request = HTTPWriteRequest(records: chunk.map(HTTPRecord.init))
            try await send(request, to: "api/v1/records", into: HTTPWriteAck.self)
        }
    }

    private struct HTTPWriteAck: Decodable {
        let saved: Int
    }
}
