//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

struct NativeDatabase: Sendable {
    let resolve: @Sendable () async throws -> EntityStore
}

extension NativeDatabase: DatabaseWriter {
    func write(record: Record) async throws {
        try await write(records: [record])
    }

    func write(records: [Record]) async throws {
        let store = try await resolve()
        for (entity, group) in Dictionary(grouping: records, by: \.recordType) {
            let batch = group.map { EntityWrite(values: Self.values(for: $0), uuid: $0.recordID) }
            try await store.write(batch, entity: entity)
        }
    }

    private static func values(for record: Record) -> [String: ScoutDB.RecordValue] {
        var values = record.storeValues
        values.merge(EntityCatalog.derivedValues(for: record)) { _, derived in derived }
        return values
    }
}

extension NativeDatabase: DatabaseReader {
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        let store = try await resolve()
        let entity = query.recordType.recordType
        let sort = query.sort.first

        let builder = query.filters.reduce(store.query(entity)) { $0.filter($1) }

        let records = try await builder.records(
            orderedBy: sort?.field ?? EntityCatalog.dateField(for: entity),
            ascending: sort?.ascending ?? false
        )

        return RecordChunk(records: records.map(Record.init(entityRecord:)), cursor: nil)
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        guard let sort = query.sort.first else {
            return try await read(matching: query, fields: fields)
        }
        return try await resolve().page(
            entity: query.recordType.recordType,
            filters: query.filters,
            field: sort.field,
            ascending: sort.ascending,
            limit: limit,
            after: nil
        )
    }
}

extension NativeDatabase {
    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        guard let entityRecord = try await resolve().fetch(uuid: recordName) else {
            throw RecordNotFoundError()
        }
        return Record(entityRecord: entityRecord)
    }
}

extension NativeDatabase {
    func series(matching query: SeriesQuery) async throws -> [MetricSeries] {
        try await NativeSeries(query: query).series(store: resolve())
    }
}

extension NativeDatabase {
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        let store = try await resolve()
        let lookback = range.lowerBound.addingTimeInterval(-30 * .day).startOfDay
        let window = lookback..<range.upperBound

        async let markers = store.visits(
            entity: VisitEntry.recordType,
            dateField: "date",
            in: window
        )
        async let sessions = store.visits(
            entity: SessionEntry.recordType,
            dateField: "start_date",
            in: window
        )

        return ActivityPoint.points(visits: try await markers + sessions, in: range)
    }
}

extension NativeDatabase {
    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        let store = try await resolve()

        async let installs = store.datedIDs(
            entity: InstallEntry.recordType,
            dateField: "date",
            idField: "install_id",
            in: range
        )
        async let sessions = store.datedIDs(
            entity: SessionEntry.recordType,
            dateField: "start_date",
            idField: "install_id",
            in: range
        )

        var installDays: [String: Date] = [:]
        for install in try await installs {
            installDays[install.id] = install.date
        }

        var sessionDays: [String: Set<Date>] = [:]
        for session in try await sessions {
            sessionDays[session.id, default: []].insert(session.date.startOfDay)
        }

        return RetentionCohort.build(
            installDays: installDays,
            sessionDays: sessionDays,
            in: range,
            asOf: Date()
        )
    }
}
