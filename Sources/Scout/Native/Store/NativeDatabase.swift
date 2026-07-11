//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutDB

// Scout's neutral record layer served by a scout-db EntityStore: raw records
// live in Item slots, while matrix reads are synthesized from GridItem
// aggregate views and from raw entities.
struct NativeDatabase: Sendable {
    let store: EntityStore
}

extension NativeDatabase: RecordWriter {
    func write(record: Record) async throws {
        try await store.write(Self.values(for: record), entity: record.recordType, uuid: record.recordID)
    }

    func write(records: [Record]) async throws {
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

extension NativeDatabase: RecordReader {
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        try await read(matching: query, fields: fields, limit: Int.max)
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        let entity = query.recordType.recordType

        if let series = MatrixSeries(recordType: entity) {
            return RecordChunk(records: try await series.records(matching: query, store: store), cursor: nil)
        }

        let records = try await store.read(
            entity: entity,
            filters: query.filters.map(\.storeFilter),
            sort: query.sort.map { EntityStore.Sort(field: $0.field, ascending: $0.ascending) },
            fields: fields.map { keys in keys.filter { $0 != "uuid" } }
        )
        return Self.chunk(records.map(Record.init(entityRecord:)), limit: limit)
    }

    private static func chunk(_ records: [Record], limit: Int) -> RecordChunk {
        guard records.count > limit else { return RecordChunk(records: records, cursor: nil) }
        let rest = Array(records.dropFirst(limit))
        return RecordChunk(
            records: Array(records.prefix(limit)),
            cursor: RecordCursor { _ in Self.chunk(rest, limit: limit) }
        )
    }
}

extension NativeDatabase: RecordLocator {
    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        guard let entityRecord = try await store.fetch(uuid: recordName) else {
            throw RecordNotFoundError()
        }
        return Record(entityRecord: entityRecord)
    }
}

extension NativeDatabase: MetricReader {
    func metricSeries<T: SeriesScalar>(_ valueType: T.Type, category: String, in range: Range<Date>) async throws -> [MetricSeries] {
        let entity = T.seriesValues == Int.seriesValues ? IntMetricsEntry.recordType : DoubleMetricsEntry.recordType
        let prefix = category + "|"
        let points = try await store.series(
            entity: entity,
            view: EntityCatalog.metricSeriesView,
            from: range.lowerBound.startOfDay,
            to: range.upperBound
        )

        var series: [String: [MetricSeriesPoint]] = [:]
        for point in points where range.contains(point.date) && point.group.hasPrefix(prefix) {
            guard let value = point.value else { continue }
            let name = String(point.group.dropFirst(prefix.count))
            series[name, default: []].append(
                MetricSeriesPoint(date: point.date.millisecondsSince1970, value: T(value).metricValue)
            )
        }
        return series.map { MetricSeries(name: $0, category: category, points: $1) }
    }
}

extension NativeDatabase: ActivityReader {
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        // WAU/MAU windows reach back before the visible range.
        let lookback = range.lowerBound.addingTimeInterval(-30 * .day).startOfDay
        let sessions = try await store.read(
            entity: SessionEntry.recordType,
            filters: [
                EntityStore.Filter(field: "start_date", op: .greaterThanOrEquals, value: .date(lookback)),
                EntityStore.Filter(field: "start_date", op: .lessThan, value: .date(range.upperBound)),
            ],
            fields: ["start_date", "device_id"]
        )

        let visits = sessions.compactMap { record -> ActivityVisit? in
            guard case .date(let date)? = record.values["start_date"] else { return nil }
            guard case .string(let user)? = record.values["device_id"] else { return nil }
            return ActivityVisit(date: date, user: user)
        }
        return ActivityPoint.points(visits: visits, in: range)
    }
}
