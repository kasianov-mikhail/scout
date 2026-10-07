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

struct NativeLastValueScanner {
    let query: MetricSeriesQuery
    let store: EntityStore

    func series(values: MetricSeriesQuery.Values) async throws -> [MetricSeries] {
        let records = try await store.records(
            entity: values.metricsEntity,
            dateField: "date",
            in: query.bucket.start(of: query.range.lowerBound)..<query.range.upperBound
        )

        let samples = records.compactMap {
            Sample(record: $0, query: query)
        }

        var latest = LatestValues()

        for sample in samples {
            latest.add(
                sample.value,
                key: sample.key,
                date: sample.date,
                start: query.bucket.start(of: sample.date)
            )
        }

        return latest.series
    }

    private struct Sample {
        let key: SeriesKey
        let date: Date
        let value: Double

        init?(record: EntityRecord, query: MetricSeriesQuery) {
            guard case .date(let date)? = record.values["date"] else {
                return nil
            }

            let name: String? = record["name"]
            let category: String? = record["category"]

            guard let name, let key = query.key(metric: name, category: category) else {
                return nil
            }

            switch record.values["value"] {
            case .double(let raw):
                self.value = raw
            case .int(let raw):
                self.value = Double(raw)
            default:
                return nil
            }

            self.date = date
            self.key = key
        }
    }
}
