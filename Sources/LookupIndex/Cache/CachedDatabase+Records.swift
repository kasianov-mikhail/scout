//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@available(iOS 18, macOS 15, *)
extension CachedDatabase: RecordReader {
    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        let fingerprint = Self.fingerprint(scope: scope, recordName: recordName, fields: fields)

        if let record = await cache.lookupRecord(for: fingerprint) {
            return record
        }

        let record = try await base.lookup(
            recordName: recordName,
            fields: fields
        )

        if types.contains(record.recordType) {
            await cache.storeLookup(record, for: fingerprint)
        }

        return record
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        try await base.read(matching: query, fields: fields, limit: limit)
    }
}

@available(iOS 18, macOS 15, *)
extension CachedDatabase {
    static func fingerprint(scope: String, recordName: String, fields: [String]?) -> String {
        [
            scope,
            "lookup",
            recordName,
            fields.map { $0.sorted().joined(separator: ",") } ?? "*",
        ]
        .joined(separator: "|")
    }
}
