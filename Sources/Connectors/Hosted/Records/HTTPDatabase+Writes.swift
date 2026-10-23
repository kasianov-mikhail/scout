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
        for chunk in records.chunked(into: 400) {
            try await requireBackgroundTime()
            let request = HTTPWriteRequest(records: chunk.map(HTTPRecord.init))
            do {
                try await send(request, to: "api/v1/records", into: HTTPWriteAck.self)
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                await access.invalidate()
                throw error
            }
        }
    }

    private struct HTTPWriteAck: Decodable {
        let saved: Int
    }
}
