//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutDB

struct MatrixSeries {
    enum Scalar {
        case int, double
    }

    let scalar: Scalar

    init?(recordType: String) {
        switch recordType {
        case Int.recordType: scalar = .int
        case Double.recordType: scalar = .double
        default: return nil
        }
    }

    func records(matching query: RecordQuery, store: EntityStore) async throws -> [Record] {
        let (from, to, name) = Self.parse(query.filters)

        switch scalar {
        case .double:
            return try await metricRecords(
                entity: DoubleMetricsEntry.recordType, from: from, to: to, name: name, store: store)

        case .int where name == nil:
            async let events = eventRecords(from: from, to: to, name: nil, store: store)
            async let metrics = metricRecords(
                entity: IntMetricsEntry.recordType, from: from, to: to, name: nil, store: store)
            async let crashes = entityRecords(.crashes, from: from, to: to, store: store)
            async let hangs = entityRecords(.hangs, from: from, to: to, store: store)
            async let installs = entityRecords(.versionInstalls, from: from, to: to, store: store)
            async let crashedInstalls = entityRecords(.versionCrashes, from: from, to: to, store: store)
            return try await events + metrics + crashes + hangs + installs + crashedInstalls

        case .int:
            switch name {
            case SessionEntry.recordType:
                return try await entityRecords(.sessions, from: from, to: to, store: store)
            case CrashEntry.recordType:
                return try await entityRecords(.crashes, from: from, to: to, store: store)
            case HangEntry.recordType:
                return try await entityRecords(.hangs, from: from, to: to, store: store)
            case MarkerEntry.installName:
                return try await entityRecords(.versionInstalls, from: from, to: to, store: store)
            case MarkerEntry.crashName:
                return try await entityRecords(.versionCrashes, from: from, to: to, store: store)
            default:
                async let events = eventRecords(from: from, to: to, name: name, store: store)
                async let metrics = metricRecords(
                    entity: IntMetricsEntry.recordType, from: from, to: to, name: name, store: store)
                return try await events + metrics
            }
        }
    }

    private static func parse(_ filters: [RecordQuery.Filter]) -> (from: Date?, to: Date?, name: String?) {
        var from: Date?
        var to: Date?
        var name: String?

        for filter in filters {
            switch (filter.field, filter.op, filter.value) {
            case ("date", .greaterThanOrEquals, .date(let date)): from = date
            case ("date", .lessThan, .date(let date)): to = date
            case ("name", .equals, .string(let value)): name = value
            default: break
            }
        }
        return (from, to, name)
    }

    private func eventRecords(from: Date?, to: Date?, name: String?, store: EntityStore) async throws -> [Record] {
        let points = try await store.series(
            entity: EventEntry.recordType, view: EntityCatalog.eventCountView, from: from?.startOfDay, to: to)
        var buckets: [SeriesBucket: [CellIndex: Double]] = [:]

        for point in points where name == nil || point.group == name {
            let week = point.date.startOfWeek
            let bucket = SeriesBucket(name: point.group, category: nil, version: nil, week: week)
            let index = Self.cellIndex(for: point.date, startOfDay: point.date.startOfDay, startOfWeek: week)
            buckets[bucket, default: [:]][index, default: 0] += Double(point.count)
        }
        return assemble(buckets)
    }

    private func metricRecords(entity: String, from: Date?, to: Date?, name: String?, store: EntityStore) async throws
        -> [Record]
    {
        let points = try await store.series(
            entity: entity, view: EntityCatalog.metricSeriesView, from: from?.startOfDay, to: to)
        var buckets: [SeriesBucket: [CellIndex: Double]] = [:]

        for point in points {
            guard let separator = point.group.firstIndex(of: "|") else { continue }
            let category = String(point.group[..<separator])
            let metric = String(point.group[point.group.index(after: separator)...])
            guard name == nil || metric == name else { continue }

            let week = point.date.startOfWeek
            let bucket = SeriesBucket(name: metric, category: category, version: nil, week: week)
            let index = Self.cellIndex(for: point.date, startOfDay: point.date.startOfDay, startOfWeek: week)
            buckets[bucket, default: [:]][index, default: 0] += point.value ?? Double(point.count)
        }
        return assemble(buckets)
    }

    private enum Source {
        case sessions, crashes, hangs, versionInstalls, versionCrashes
    }

    private func entityRecords(_ source: Source, from: Date?, to: Date?, store: EntityStore) async throws -> [Record] {
        let (entity, dateField, matrixName) = Self.layout(of: source)
        var filters: [EntityStore.Filter] = []
        if let from {
            filters.append(
                EntityStore.Filter(field: dateField, op: .greaterThanOrEquals, value: .date(from.startOfDay)))
        }
        if let to {
            filters.append(EntityStore.Filter(field: dateField, op: .lessThan, value: .date(to)))
        }

        let records = try await store.read(
            entity: entity, filters: filters, fields: [dateField, "app_version", "install_id"])
        var visits = records.compactMap { record -> (date: Date, version: String?, install: String?)? in
            guard case .date(let date)? = record.values[dateField] else { return nil }
            let version: String? = record["app_version"]
            let install: String? = record["install_id"]
            return (date, version, install)
        }

        if source == .versionCrashes {
            var first: [String: (date: Date, version: String?, install: String?)] = [:]
            for visit in visits {
                let key = (visit.install ?? "") + "@" + (visit.version ?? "")
                if let existing = first[key], existing.date <= visit.date { continue }
                first[key] = visit
            }
            visits = Array(first.values)
        }

        var buckets: [SeriesBucket: [CellIndex: Double]] = [:]
        for visit in visits {
            let week = visit.date.startOfWeek
            let bucket = SeriesBucket(name: matrixName, category: nil, version: visit.version, week: week)
            let index = Self.cellIndex(for: visit.date, startOfDay: visit.date.startOfDay, startOfWeek: week)
            buckets[bucket, default: [:]][index, default: 0] += 1
        }
        return assemble(buckets)
    }

    private static func layout(of source: Source) -> (entity: String, dateField: String, matrixName: String) {
        switch source {
        case .sessions:
            (SessionEntry.recordType, "start_date", SessionEntry.recordType)
        case .crashes:
            (CrashEntry.recordType, "date", CrashEntry.recordType)
        case .hangs:
            (HangEntry.recordType, "date", HangEntry.recordType)
        case .versionInstalls:
            (VersionEntry.recordType, "date", MarkerEntry.installName)
        case .versionCrashes:
            (CrashEntry.recordType, "date", MarkerEntry.crashName)
        }
    }

    private struct SeriesBucket: Hashable {
        let name: String
        let category: String?
        let version: String?
        let week: Date
    }

    private struct CellIndex: Hashable {
        let row: Int
        let column: Int
    }

    // Takes the already-derived startOfDay/startOfWeek so the per-point loops
    // reuse the week they compute for the bucket instead of recomputing it here.
    private static func cellIndex(for date: Date, startOfDay: Date, startOfWeek: Date) -> CellIndex {
        let row = Int(startOfDay.timeIntervalSince(startOfWeek) / .day) + 1
        let column = Int(date.timeIntervalSince(startOfDay) / .hour)
        return CellIndex(row: row, column: column)
    }

    private static func cellKey(_ index: CellIndex) -> String {
        "cell_\(index.row)_\(index.column.leadingZero)"
    }

    private func assemble(_ buckets: [SeriesBucket: [CellIndex: Double]]) -> [Record] {
        buckets.map { bucket, cells in
            var record = Record(
                recordType: scalar == .int ? Int.recordType : Double.recordType,
                recordID: UUID().uuidString
            )
            record["date"] = bucket.week
            record["name"] = bucket.name
            record["category"] = bucket.category
            record["app_version"] = bucket.version
            for (index, value) in cells {
                record.fields[Self.cellKey(index)] = scalar == .int ? .int(Int64(value)) : .double(value)
            }
            return record
        }
    }
}
