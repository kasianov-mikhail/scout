//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorSupport
import Foundation
import Scout
import ScoutDB

struct NativeLifecycleScanner {
    let query: LifecycleSeriesQuery
    let store: EntityStore
    let scans: ScanFlights

    var series: [MetricSeries] {
        get async throws {
            let range = query.bucket.start(of: query.range.lowerBound)..<query.range.upperBound

            if let entity = firstSeenEntities[query.name] {
                return try await firstSeen(entity: entity, range: range).series
            }

            let source = LifecycleSource(name: query.name)
            let points = try await store.query(source.entity)
                .series(source.field, metric: .sum, group: CatalogEntry.lifecycleKey, in: range)

            var totals = SeriesTotals()

            for point in points {
                let key = LifecycleKey(point.group)

                guard source.field == nil || key.name == query.name else {
                    continue
                }

                let series = SeriesKey(
                    name: query.name,
                    category: key.category,
                    version: query.byVersion ? key.version : nil
                )

                totals.add(point.value, key: series, start: query.bucket.start(of: point.date))
            }

            return totals.series
        }
    }

    private func firstSeen(entity: String, range: Range<Date>) async throws -> SeriesTotals {
        let key = ScanKey(entity: entity, dateField: "date", range: .distantPast..<range.upperBound)

        let records = try await scans.records(key: key) { [store] in
            try await store.records(
                entity: key.entity,
                dateField: key.dateField,
                fields: [key.dateField, "app_version", "install_id"],
                in: key.range
            )
        }

        var totals = SeriesTotals()

        for visit in records.compactMap(VersionVisit.init).firstPerInstall where range.contains(visit.date) {
            let key = SeriesKey(name: query.name, category: nil, version: query.byVersion ? visit.version : nil)
            totals.add(1, key: key, start: query.bucket.start(of: visit.date))
        }

        return totals
    }
}

private let firstSeenEntities = [
    MarkerEntry.crashName: CrashEntry.recordType,
    MarkerEntry.installName: VersionEntry.recordType,
]

private struct LifecycleSource {
    let entity: String
    let field: String?

    init(name: String) {
        let counted = [
            SessionEntry.recordType,
            CrashEntry.recordType,
            HangEntry.recordType,
            VersionEntry.recordType,
            ResourceEntry.recordType,
            ScreenEntry.recordType,
            ConditionEntry.recordType,
        ]

        entity = counted.contains(name) ? name : DailyMetricEntry.recordType
        field = counted.contains(name) ? nil : "value"
    }
}

private struct VersionVisit {
    let date: Date
    let version: String?
    let install: String?

    init?(record: EntityRecord) {
        guard case .date(let date)? = record.values["date"] else {
            return nil
        }

        self.date = date
        self.version = record["app_version"]
        self.install = record["install_id"]
    }
}

private struct InstallVersion: Hashable {
    let install: String
    let version: String
}

extension [VersionVisit] {
    fileprivate var firstPerInstall: [VersionVisit] {
        Dictionary(grouping: self) { InstallVersion(install: $0.install ?? "", version: $0.version ?? "") }
            .values
            .compactMap { $0.min { $0.date < $1.date } }
    }
}
