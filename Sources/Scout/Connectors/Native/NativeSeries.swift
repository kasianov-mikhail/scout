//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

struct NativeSeries {
    let query: SeriesQuery

    func series(store: EntityStore) async throws -> [MetricSeries] {
        var intTotals: [GroupKey: [Date: Double]] = [:]
        var doubleTotals: [GroupKey: [Date: Double]] = [:]

        if query.values != "double" {
            try await collectInt(into: &intTotals, store: store)
        }
        if query.values != "int" {
            try await collectMetrics(entity: DoubleMetricsEntry.recordType, into: &doubleTotals, store: store)
        }

        var series: [MetricSeries] = []
        for (key, totals) in intTotals {
            series.append(assemble(key, totals) { .int(Int($0)) })
        }
        for (key, totals) in doubleTotals where query.values != nil || intTotals[key] == nil {
            series.append(assemble(key, totals) { .double($0) })
        }

        return
            series
            .filter { $0.points.count > 0 }
            .sorted { ($0.name, $0.category ?? "", $0.version ?? "") < ($1.name, $1.category ?? "", $1.version ?? "") }
    }

    private var from: Date {
        bucketStart(of: query.range.lowerBound)
    }

    private func bucketStart(of date: Date) -> Date {
        switch query.bucket {
        case .hour: date.startOfHour
        case .day: date.startOfDay
        case .week: date.startOfWeek
        }
    }

    private func collectInt(into totals: inout [GroupKey: [Date: Double]], store: EntityStore) async throws {
        switch (query.name, query.category) {
        case (nil, nil):
            try await collectEvents(name: nil, into: &totals, store: store)
            try await collectCounts(of: .crashes, into: &totals, store: store)
            try await collectCounts(of: .hangs, into: &totals, store: store)
            try await collectMetrics(entity: IntMetricsEntry.recordType, into: &totals, store: store)
        case (SessionEntry.recordType, nil):
            try await collectCounts(of: .sessions, into: &totals, store: store)
        case (CrashEntry.recordType, nil):
            try await collectCounts(of: .crashes, into: &totals, store: store)
        case (HangEntry.recordType, nil):
            try await collectCounts(of: .hangs, into: &totals, store: store)
        case (VersionEntry.recordType, nil):
            try await collectCounts(of: .installs, into: &totals, store: store)
        case (MarkerEntry.crashName, nil):
            try await collectCounts(of: .firstCrashes, into: &totals, store: store)
        case (let name?, nil):
            try await collectEvents(name: name, into: &totals, store: store)
            try await collectMetrics(entity: IntMetricsEntry.recordType, into: &totals, store: store)
        default:
            try await collectMetrics(entity: IntMetricsEntry.recordType, into: &totals, store: store)
        }
    }

    private func collectEvents(name: String?, into totals: inout [GroupKey: [Date: Double]], store: EntityStore)
        async throws
    {
        let points = try await store.series(
            entity: EventEntry.recordType, view: EntityCatalog.eventCountView, from: from, to: query.range.upperBound)

        for point in points where point.date >= from && (name == nil || point.group == name) {
            add(Double(point.count), name: point.group, category: nil, version: nil, date: point.date, to: &totals)
        }
    }

    private func collectMetrics(entity: String, into totals: inout [GroupKey: [Date: Double]], store: EntityStore)
        async throws
    {
        let points = try await store.series(
            entity: entity, view: EntityCatalog.metricSeriesView, from: from, to: query.range.upperBound)

        for point in points where point.date >= from {
            guard let (category, metric) = EntityCatalog.decodeSeriesKey(point.group) else { continue }

            guard query.name == nil || metric == query.name else { continue }
            guard query.category == nil || category == query.category else { continue }

            add(
                point.value ?? Double(point.count),
                name: metric,
                category: category.isEmpty ? nil : category,
                version: nil,
                date: point.date,
                to: &totals
            )
        }
    }

    private enum Source {
        case sessions, crashes, hangs, installs, firstCrashes
    }

    private func collectCounts(of source: Source, into totals: inout [GroupKey: [Date: Double]], store: EntityStore)
        async throws
    {
        let (entity, dateField, name) = Self.layout(of: source)
        let filters = [
            EntityStore.Filter(field: dateField, op: .greaterThanOrEquals, value: .date(from)),
            EntityStore.Filter(field: dateField, op: .lessThan, value: .date(query.range.upperBound)),
        ]

        let records = try await store.read(
            entity: entity, filters: filters, fields: [dateField, "app_version", "install_id"])
        var visits = records.compactMap { record -> (date: Date, version: String?, install: String?)? in
            guard case .date(let date)? = record.values[dateField] else { return nil }
            let version: String? = record["app_version"]
            let install: String? = record["install_id"]
            return (date, version, install)
        }

        if source == .firstCrashes {
            var first: [String: (date: Date, version: String?, install: String?)] = [:]
            for visit in visits {
                let key = (visit.install ?? "") + "@" + (visit.version ?? "")
                if let existing = first[key], existing.date <= visit.date { continue }
                first[key] = visit
            }
            visits = Array(first.values)
        }

        for visit in visits {
            add(
                1,
                name: name,
                category: nil,
                version: query.byVersion ? visit.version : nil,
                date: visit.date,
                to: &totals
            )
        }
    }

    private static func layout(of source: Source) -> (entity: String, dateField: String, name: String) {
        switch source {
        case .sessions:
            (SessionEntry.recordType, "start_date", SessionEntry.recordType)
        case .crashes:
            (CrashEntry.recordType, "date", CrashEntry.recordType)
        case .hangs:
            (HangEntry.recordType, "date", HangEntry.recordType)
        case .installs:
            (VersionEntry.recordType, "date", VersionEntry.recordType)
        case .firstCrashes:
            (CrashEntry.recordType, "date", MarkerEntry.crashName)
        }
    }

    private func add(
        _ value: Double, name: String, category: String?, version: String?, date: Date,
        to totals: inout [GroupKey: [Date: Double]]
    ) {
        let key = GroupKey(name: name, category: category, version: version)
        totals[key, default: [:]][bucketStart(of: date), default: 0] += value
    }

    private func assemble(_ key: GroupKey, _ totals: [Date: Double], value: (Double) -> MetricValue) -> MetricSeries {
        let points =
            totals
            .filter { $0.value != 0 }
            .sorted { $0.key < $1.key }
            .map { MetricSeriesPoint(date: $0.key.millisecondsSince1970, value: value($0.value)) }
        return MetricSeries(name: key.name, category: key.category, version: key.version, points: points)
    }

    private struct GroupKey: Hashable {
        let name: String
        let category: String?
        let version: String?
    }
}
