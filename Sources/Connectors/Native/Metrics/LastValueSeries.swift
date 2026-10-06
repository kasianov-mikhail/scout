//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

struct LastValueSeries {
    let query: MetricSeriesQuery
    let store: EntityStore

    func series() async throws -> [MetricSeries] {
        async let ints = query.values == .double ? [] : series(values: .int)
        async let doubles = query.values == .int ? [] : series(values: .double)

        return try await [MetricSeries](
            ints: ints,
            doubles: doubles,
            values: query.values
        )
    }

    private func series(values: MetricSeriesQuery.Values) async throws -> [MetricSeries] {
        let records = try await store.records(
            entity: values.metricsEntity,
            dateField: "date",
            in: query.window
        )

        let samples = records.compactMap {
            Sample(record: $0, query: query)
        }

        var latest = LatestValues()

        for sample in samples {
            latest.add(sample.value, key: sample.key, date: sample.date, bucket: query.bucket)
        }

        return latest.series(values: values)
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

            guard let name else {
                return nil
            }
            guard query.matches(name: name, category: category) else {
                return nil
            }

            switch record.values["value"] {
            case .double(let raw):
                value = raw
            case .int(let raw):
                value = Double(raw)
            default:
                return nil
            }

            self.date = date

            key = SeriesKey(metric: name, category: category)
        }
    }
}
