//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

struct NativeLifecycleSeries {
    let query: LifecycleSeriesQuery
    let store: EntityStore

    func series() async throws -> [MetricSeries] {
        let counter = query.counter

        let records = try await store.records(
            entity: counter.entity,
            dateField: counter.dateField,
            in: query.window
        )

        let visits = records.compactMap {
            LifecycleVisit(record: $0, dateField: counter.dateField)
        }

        var totals = SeriesTotals()

        for visit in counter == .firstCrashes ? visits.firstPerInstall : visits {
            let key = SeriesKey(
                name: counter.name,
                category: nil,
                version: query.byVersion ? visit.version : nil
            )

            totals.add(1, key: key, date: visit.date, bucket: query.bucket)
        }

        return totals.series(values: .int)
    }
}

extension LifecycleCounter {
    fileprivate var entity: String {
        switch self {
        case .sessions:
            SessionEntry.recordType
        case .crashes, .firstCrashes:
            CrashEntry.recordType
        case .hangs:
            HangEntry.recordType
        case .installs:
            VersionEntry.recordType
        }
    }

    fileprivate var dateField: String {
        self == .sessions ? "start_date" : "date"
    }
}

private struct LifecycleVisit {
    let date: Date
    let version: String?
    let install: String?

    init?(record: EntityRecord, dateField: String) {
        guard case .date(let date)? = record.values[dateField] else {
            return nil
        }

        self.date = date
        version = record["app_version"]
        install = record["install_id"]
    }

    var installKey: String {
        (install ?? "") + "@" + (version ?? "")
    }
}

extension [LifecycleVisit] {
    fileprivate var firstPerInstall: [LifecycleVisit] {
        var first: [String: LifecycleVisit] = [:]

        for visit in self {
            if let existing = first[visit.installKey], existing.date <= visit.date {
                continue
            }

            first[visit.installKey] = visit
        }

        return Array(first.values)
    }
}
