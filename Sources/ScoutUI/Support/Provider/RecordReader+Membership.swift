//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

private let membershipLimit = 250

extension RecordReader {
    func readAll(type: any RecordDecodable.Type, field: String, values: [String], fields: [String]?) async throws -> [Record] {
        try await values.readInMembershipChunks { chunk in
            let query = RecordQuery(
                recordType: type,
                filters: [RecordQuery.Filter(field: field, op: .in, value: .strings(chunk))]
            )
            return try await readAll(matching: query, fields: fields)
        }
        .flatMap { try $0.get() }
    }
}

extension Array where Element: Sendable {
    func readInMembershipChunks<Output: Sendable>(read: @escaping @Sendable ([Element]) async throws -> Output) async -> [Result<Output, any Error>] {
        await withTaskGroup(of: Result<Output, any Error>.self) { group in
            for start in stride(from: 0, to: count, by: membershipLimit) {
                let chunk = Array(self[start..<Swift.min(start + membershipLimit, count)])
                group.addTask {
                    do {
                        return .success(try await read(chunk))
                    } catch {
                        return .failure(error)
                    }
                }
            }
            return await group.reduce(into: []) { $0.append($1) }
        }
    }
}
