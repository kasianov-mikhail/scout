//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@MainActor
final class MetricsListProvider: ObservableObject, SeriesProvider {
    @Published var result: ProviderResult<[MetricTile]>?
    @Published var range: MetricRange

    private let now: () -> Date

    init(_ result: ProviderResult<[MetricTile]>? = nil, range: MetricRange = .today, now: @escaping () -> Date = Date.init) {
        self.result = result
        self.range = range
        self.now = now
    }

    func load(in database: SeriesReader) async {
        guard !ProcessInfo.processInfo.isPreview else {
            return
        }

        result = nil

        do {
            result = .success(try await fetch(in: database))
        } catch is CancellationError {
        } catch {
            result = .failure(error)
        }
    }

    func fetch(in database: SeriesReader) async throws -> [MetricTile] {
        let selection = range
        let metricRange = selection.range(now: now())
        let bucket = selection.bucket

        async let intSeries = database.metricSeries(
            matching: MetricSeriesQuery(values: .int, bucket: bucket, reduce: .sum, range: metricRange)
        )
        async let floatingSeries = database.metricSeries(
            matching: MetricSeriesQuery(
                category: Telemetry.Export.floatingCounter.rawValue,
                values: .double,
                bucket: bucket,
                reduce: .sum,
                range: metricRange
            )
        )
        async let meterSeries = database.metricSeries(
            matching: MetricSeriesQuery(
                category: Telemetry.Export.meter.rawValue,
                values: .double,
                bucket: bucket,
                reduce: .last,
                range: metricRange
            )
        )

        return MetricTileBuilder(
            intSeries: try await intSeries,
            floatingSeries: try await floatingSeries,
            meterSeries: try await meterSeries,
            range: metricRange
        ).tiles
    }
}
