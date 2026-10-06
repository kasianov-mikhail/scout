//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension DemoDatabase: SeriesReader {
    func eventSeries(matching query: EventSeriesQuery) async throws -> [MetricSeries] {
        DemoSeriesFilter(
            source: .event,
            name: query.name,
            bucket: query.bucket,
            range: query.range
        )
        .series(in: samples)
    }

    func lifecycleSeries(matching query: LifecycleSeriesQuery) async throws -> [MetricSeries] {
        DemoSeriesFilter(
            source: .lifecycle,
            name: query.name,
            byVersion: query.byVersion,
            bucket: query.bucket,
            range: query.range
        )
        .series(in: samples)
    }

    func metricSeries(matching query: MetricSeriesQuery) async throws -> [MetricSeries] {
        DemoSeriesFilter(
            source: .metric,
            name: query.name,
            category: query.category,
            values: query.values,
            reduce: query.reduce,
            bucket: query.bucket,
            range: query.range
        )
        .series(in: samples)
    }
}
