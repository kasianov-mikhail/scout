//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension NativeDatabase: SeriesReader {
    func eventSeries(matching query: EventSeriesQuery) async throws -> [MetricSeries] {
        try await NativeEventSeries(query: query, store: resolve()).series().nonEmptySorted
    }

    func lifecycleSeries(matching query: LifecycleSeriesQuery) async throws -> [MetricSeries] {
        try await NativeLifecycleSeries(query: query, store: resolve()).series().nonEmptySorted
    }

    func metricSeries(matching query: MetricSeriesQuery) async throws -> [MetricSeries] {
        try await NativeMetricSeries(query: query, store: resolve()).series().nonEmptySorted
    }
}
