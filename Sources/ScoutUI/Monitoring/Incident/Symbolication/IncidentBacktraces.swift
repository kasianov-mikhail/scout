//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//
import Foundation
import Scout

private let membershipLimit = 250

struct IncidentBacktraces {
    let details: [String: BacktraceDetail]

    init(incidentIDs: [String], database: RecordReader) async throws {
        let records = try await database.backtraces(incidentIDs: incidentIDs)

        var backtraces: [String: Backtrace] = [:]
        for record in records {
            backtraces[record.incidentID] = try JSONDecoder().decode(Backtrace.self, from: record.payload)
        }

        let uuids = Array(Set(backtraces.values.flatMap(\.images).compactMap(\.uuid)))
        let tables = await SymbolTableCache.shared.tables(uuids: uuids, database: database)
        details = backtraces.mapValues { BacktraceDetail(backtrace: $0, tables: tables) }
    }

    var groupKeys: [String: String] {
        details.compactMapValues(\.groupKey)
    }
}

extension RecordReader {
    fileprivate func backtraces(incidentIDs: [String]) async throws -> [BacktraceRecord] {
        let values = incidentIDs.compactMap(UUID.init).map { UUID(incidentBacktrace: $0).uuidString }

        return try await withThrowingTaskGroup(of: [BacktraceRecord].self) { group in
            for start in stride(from: 0, to: values.count, by: membershipLimit) {
                let query = RecordQuery(
                    recordType: BacktraceRecord.self,
                    filters: [
                        RecordQuery.Filter(
                            field: "uuid",
                            op: .in,
                            value: .strings(Array(values[start..<min(start + membershipLimit, values.count)]))
                        )
                    ]
                )
                group.addTask {
                    try await self.readAll(matching: query, fields: BacktraceRecord.desiredKeys)
                }
            }

            var records: [BacktraceRecord] = []
            for try await chunk in group {
                records += chunk
            }
            return records
        }
    }
}
