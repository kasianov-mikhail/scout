//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension RecordReader {
    func readAll(matching query: RecordQuery, fields: [String]?) async throws -> [Record] {
        var chunk = try await read(matching: query, fields: fields)
        var records = chunk.records
        while let cursor = chunk.cursor {
            chunk = try await cursor.next(fields)
            records += chunk.records
        }
        return records
    }

    func readAll<T: RecordDecodable>(matching query: RecordQuery, fields: [String]?) async throws -> [T] {
        try await readAll(matching: query, fields: fields).map(T.init)
    }
}
