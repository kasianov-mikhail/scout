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

    var series: [MetricSeries] {
        get async throws {
            let isCrash = query.name == MarkerEntry.crashName
            let dateField = query.name == SessionEntry.recordType ? "start_date" : "date"

            let entities = [
                SessionEntry.recordType,
                CrashEntry.recordType,
                HangEntry.recordType,
                VersionEntry.recordType,
                ResourceEntry.recordType,
                ScreenEntry.recordType,
            ]

            let isDailyMetric = !isCrash && !entities.contains(query.name)
            let entity = isCrash ? CrashEntry.recordType : isDailyMetric ? DailyMetricEntry.recordType : query.name

            let records = try await store.records(
                entity: entity,
                dateField: dateField,
                in: query.bucket.start(of: query.range.lowerBound)..<query.range.upperBound
            )

            let visits =
                records
                .filter { !isDailyMetric || $0["name"] == query.name }
                .compactMap { LifecycleVisit(record: $0, dateField: dateField, summed: isDailyMetric) }

            let counted = isCrash ? visits.firstPerInstall : visits

            var totals = SeriesTotals()

            for visit in counted {
                let key = SeriesKey(
                    name: query.name,
                    category: visit.category,
                    version: query.byVersion ? visit.version : nil
                )

                totals.add(Double(visit.count), key: key, start: query.bucket.start(of: visit.date))
            }

            return totals.series
        }
    }
}

private struct LifecycleVisit {
    let date: Date
    let version: String?
    let install: String?
    let category: String?
    let count: Int

    init?(record: EntityRecord, dateField: String, summed: Bool) {
        guard case .date(let date)? = record.values[dateField] else {
            return nil
        }

        self.date = date
        self.version = record["app_version"]
        self.install = record["install_id"]
        self.category = record["category"]
        self.count = summed ? record["value"] ?? 1 : 1
    }
}

private struct InstallVersion: Hashable {
    let install: String
    let version: String
}

extension [LifecycleVisit] {
    fileprivate var firstPerInstall: [LifecycleVisit] {
        Dictionary(grouping: self) { InstallVersion(install: $0.install ?? "", version: $0.version ?? "") }
            .values
            .compactMap { $0.min { $0.date < $1.date } }
    }
}
