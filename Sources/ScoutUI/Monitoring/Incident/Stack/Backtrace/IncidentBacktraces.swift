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
    let found: Set<String>

    init(incidentIDs: [String], database: RecordReader) async throws {
        let values = incidentIDs.compactMap(UUID.init).map { UUID(incidentBacktrace: $0).uuidString }

        let records = try await database.readAll(
            type: BacktraceRecord.self,
            field: "uuid",
            values: values,
            fields: BacktraceRecord.desiredKeys
        )
        .map(BacktraceRecord.init)

        found = Set(records.map(\.incidentID))

        var backtraces: [String: Backtrace] = [:]
        for record in records {
            do {
                backtraces[record.incidentID] = try JSONDecoder().decode(Backtrace.self, from: record.payload)
            } catch {
                print("Failed to decode backtrace \(record.id): \(error)")
            }
        }

        let uuids = Array(Set(backtraces.values.flatMap(\.images).compactMap(\.uuid)))
        let tables = await SymbolTableCache.shared.tables(uuids: uuids, database: database)

        details = backtraces.mapValues { BacktraceDetail(backtrace: $0, tables: tables) }
    }

    var groupKeys: [String: String] {
        details.compactMapValues(\.groupKey)
    }
}
