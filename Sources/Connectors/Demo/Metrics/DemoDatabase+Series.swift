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
        samples.series(matching: DemoSeriesFilter(query: query))
    }

    func lifecycleSeries(matching query: LifecycleSeriesQuery) async throws -> [MetricSeries] {
        samples.series(matching: DemoSeriesFilter(query: query))
    }

    func metricSeries(matching query: MetricSeriesQuery) async throws -> [MetricSeries] {
        samples.series(matching: DemoSeriesFilter(query: query))
    }
}
