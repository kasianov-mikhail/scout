//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import Foundation
import Scout

enum AlertMetric: Hashable, Codable {
    case eventCount(name: String)
    case crashFreeSessions
}

extension AlertMetric {
    func reading(in database: SeriesReader, period: some ChartTimeScale) async throws -> MetricReading {
        let range = period.previousRange.lowerBound..<period.initialRange.upperBound

        switch self {
        case .eventCount(let name):
            let series = try await database.eventSeries(
                matching: EventSeriesQuery(name: name, bucket: .hour, range: range)
            )

            return MetricReading(
                points: series.flatMap { $0.chartPoints() },
                period: period
            )

        case .crashFreeSessions:
            let points = try await StabilityPoints(database: database, range: range)

            return MetricReading(stability: points, period: period)
        }
    }

    func values(in database: SeriesReader, range: Range<Date>) async throws -> [Double] {
        switch self {
        case .eventCount(let name):
            return try await database.eventSeries(
                matching: EventSeriesQuery(name: name, bucket: .hour, range: range)
            )
            .flatMap { $0.chartPoints() as [ChartPoint<Int>] }
            .bucket(in: range, component: .hour)
            .reversed()
            .map { Double($0.value) }

        case .crashFreeSessions:
            let points = try await StabilityPoints(database: database, range: range)

            return points.values(range: range, component: .hour)
        }
    }
}
