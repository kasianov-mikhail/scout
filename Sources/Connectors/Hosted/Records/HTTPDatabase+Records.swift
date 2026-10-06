//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension HTTPDatabase: RecordReader {
    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        try await run(
            query: HTTPQuery(
                query: query,
                fields: fields,
                limit: limit
            )
        )
    }

    private func run(query: HTTPQuery) async throws -> RecordChunk {
        let response = try await send(
            query,
            to: "api/v1/records/query",
            into: HTTPQueryResponse.self
        )

        return RecordChunk(
            records: response.records.map(\.record),
            cursor: response.cursor.map { token in
                RecordCursor { _ in
                    var next = HTTPQuery()
                    next.cursor = token
                    return try await self.run(query: next)
                }
            }
        )
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        let endpoint = recordEndpoint(recordName: recordName, fields: fields)

        do {
            return try await get(
                from: endpoint,
                reason: "Malformed record URL",
                as: HTTPRecord.self
            )
            .record
        } catch let error as HTTPDatabaseError where error.status == 404 {
            throw RecordNotFoundError()
        }
    }

    func recordEndpoint(recordName: String, fields: [String]?) -> URL? {
        let allowed = CharacterSet.urlPathAllowed.subtracting(CharacterSet(charactersIn: "/"))
        let name = recordName.addingPercentEncoding(withAllowedCharacters: allowed) ?? recordName

        var path = "api/v1/records/\(name)"
        if let fields {
            path += "?fields=\(Self.encode(fields.joined(separator: ",")))"
        }
        return URL(string: path, relativeTo: url)
    }
}
