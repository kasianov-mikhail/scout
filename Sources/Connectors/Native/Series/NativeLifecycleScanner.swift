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

            guard query.name != MarkerEntry.crashName else {
                return try await crashedInstalls(range: range).series
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

    private func crashedInstalls(range: Range<Date>) async throws -> SeriesTotals {
        let key = ScanKey(entity: CrashEntry.recordType, dateField: "date", range: range)

        let records = try await scans.records(key: key) { [store] in
            try await store.records(
                entity: key.entity,
                dateField: key.dateField,
                fields: [key.dateField, "app_version", "install_id"],
                in: key.range
            )
        }

        var totals = SeriesTotals()

        for crash in records.compactMap(CrashVisit.init).firstPerInstall {
            let key = SeriesKey(name: query.name, category: nil, version: query.byVersion ? crash.version : nil)
            totals.add(1, key: key, start: query.bucket.start(of: crash.date))
        }

        return totals
    }
}

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

private struct CrashVisit {
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

extension [CrashVisit] {
    fileprivate var firstPerInstall: [CrashVisit] {
        Dictionary(grouping: self) { InstallVersion(install: $0.install ?? "", version: $0.version ?? "") }
            .values
            .compactMap { $0.min { $0.date < $1.date } }
    }
}
