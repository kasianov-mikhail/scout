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
    let store: EntityStore

    let registration: Task<Void, Never>

    init(store: EntityStore, registration: Task<Void, Never> = Task {}) {
        self.store = store
        self.registration = registration
    }
}

extension NativeDatabase: DatabaseWriter {
    func write(record: Record) async throws {
        await registration.value
        try await store.write(Self.values(for: record), entity: record.recordType, uuid: record.recordID)
    }

    func write(records: [Record]) async throws {
        await registration.value
        for (entity, group) in Dictionary(grouping: records, by: \.recordType) {
            let batch = group.map { EntityWrite(values: Self.values(for: $0), uuid: $0.recordID) }
            try await store.write(batch, entity: entity)
        }
    }

    private static func values(for record: Record) -> [String: ScoutDB.RecordValue] {
        var values = record.storeValues
        values[EntityCatalog.metricSeriesKey] = EntityCatalog.seriesKey(for: record)
        return values
    }
}

extension NativeDatabase: DatabaseReader {
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        await registration.value
        let records = try await store.read(
            entity: query.recordType.recordType,
            filters: query.filters.map(\.storeFilter),
            sort: query.sort.map { EntityStore.Sort(field: $0.field, ascending: $0.ascending) },
            fields: fields.map { keys in keys.filter { $0 != "uuid" } }
        )
        return RecordChunk(records: records.map(Record.init(entityRecord:)), cursor: nil)
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        await registration.value
        // The keyset pager orders by a single field, so a query without a sort
        // has no page order to follow — fall back to the full read.
        guard let sort = query.sort.first else {
            return try await read(matching: query, fields: fields)
        }
        return try await page(
            entity: query.recordType.recordType,
            filters: query.filters.map(\.storeFilter),
            field: sort.field,
            ascending: sort.ascending,
            limit: limit,
            after: nil
        )
    }

    // Reads one keyset page and wraps its continuation cursor so the next page
    // re-queries the store for the following bounded slice instead of retaining
    // the whole pre-fetched tail in memory.
    private func page(
        entity: String, filters: [EntityStore.Filter], field: String, ascending: Bool, limit: Int,
        after cursor: FieldCursor?
    ) async throws
        -> RecordChunk
    {
        let page = try await store.read(
            entity: entity, filters: filters, orderedBy: field, descending: !ascending, limit: limit, after: cursor)
        return RecordChunk(
            records: page.records.map(Record.init(entityRecord:)),
            cursor: page.cursor.map { next in
                RecordCursor { _ in
                    try await self.page(
                        entity: entity, filters: filters, field: field, ascending: ascending, limit: limit, after: next)
                }
            }
        )
    }
}

extension NativeDatabase {
    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        await registration.value
        guard let entityRecord = try await store.fetch(uuid: recordName) else {
            throw RecordNotFoundError()
        }
        return Record(entityRecord: entityRecord)
    }
}

extension NativeDatabase {
    func series(matching query: SeriesQuery) async throws -> [MetricSeries] {
        await registration.value
        return try await NativeSeries(query: query).series(store: store)
    }
}

extension NativeDatabase {
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        await registration.value
        // WAU/MAU windows reach back before the visible range.
        let lookback = range.lowerBound.addingTimeInterval(-30 * .day).startOfDay

        // Visit markers carry one record per device per day; sessions still
        // back the days written before markers existed. The union dedupes, so
        // dropping the session leg once every client ships markers is safe.
        let window = lookback..<range.upperBound
        async let markers = visits(entity: VisitEntry.recordType, dateField: "date", in: window)
        async let sessions = visits(entity: SessionEntry.recordType, dateField: "start_date", in: window)

        return ActivityPoint.points(visits: try await markers + sessions, in: range)
    }

    private func visits(entity: String, dateField: String, in window: Range<Date>) async throws -> [ActivityVisit] {
        let records = try await store.read(
            entity: entity,
            filters: [
                EntityStore.Filter(field: dateField, op: .greaterThanOrEquals, value: .date(window.lowerBound)),
                EntityStore.Filter(field: dateField, op: .lessThan, value: .date(window.upperBound)),
            ],
            fields: [dateField, "device_id"]
        )

        return records.compactMap { record -> ActivityVisit? in
            guard case .date(let date)? = record.values[dateField] else { return nil }
            guard case .string(let user)? = record.values["device_id"] else { return nil }
            return ActivityVisit(date: date, user: user)
        }
    }
}

extension NativeDatabase {
    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        await registration.value

        let installs = try await store.read(
            entity: InstallEntry.recordType,
            filters: [
                EntityStore.Filter(field: "date", op: .greaterThanOrEquals, value: .date(range.lowerBound)),
                EntityStore.Filter(field: "date", op: .lessThan, value: .date(range.upperBound)),
            ],
            fields: ["date", "install_id"]
        )

        var installDays: [String: Date] = [:]
        for record in installs {
            guard case .date(let date)? = record.values["date"] else { continue }
            guard case .string(let install)? = record.values["install_id"] else { continue }
            installDays[install] = date
        }

        let sessions = try await store.read(
            entity: SessionEntry.recordType,
            filters: [
                EntityStore.Filter(field: "start_date", op: .greaterThanOrEquals, value: .date(range.lowerBound)),
                EntityStore.Filter(field: "start_date", op: .lessThan, value: .date(range.upperBound)),
            ],
            fields: ["start_date", "install_id"]
        )

        var sessionDays: [String: Set<Date>] = [:]
        for record in sessions {
            guard case .date(let date)? = record.values["start_date"] else { continue }
            guard case .string(let install)? = record.values["install_id"] else { continue }
            sessionDays[install, default: []].insert(date.startOfDay)
        }

        return RetentionCohort.build(installDays: installDays, sessionDays: sessionDays, in: range, asOf: Date())
    }
}
