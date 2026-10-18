//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//
import Foundation
import Scout

struct IncidentBacktraces {
    let details: [String: BacktraceDetail]

    init(range: Range<Date>, database: RecordReader) async throws {
        let query = RecordQuery(
            recordType: BacktraceRecord.self,
            filters: [
                RecordQuery.Filter(field: "date", op: .greaterThanOrEquals, value: .date(range.lowerBound)),
                RecordQuery.Filter(field: "date", op: .lessThan, value: .date(range.upperBound)),
            ]
        )
        let records: [BacktraceRecord] = try await database.readAll(matching: query, fields: BacktraceRecord.desiredKeys)

        var backtraces: [String: Backtrace] = [:]
        for record in records {
            backtraces[record.incidentID] = try JSONDecoder().decode(Backtrace.self, from: record.payload)
        }

        let uuids = Array(Set(backtraces.values.flatMap(\.images).compactMap(\.uuid)))
        let tables = try await SymbolTableCache.shared.tables(uuids: uuids, database: database)
        details = backtraces.mapValues { BacktraceDetail(backtrace: $0, tables: tables) }
    }

    var groupKeys: [String: String] {
        details.compactMapValues(\.groupKey)
    }
}
