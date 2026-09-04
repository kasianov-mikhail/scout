//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

enum AlertMetric: Hashable, Codable {
    case eventCount(name: String)
    case crashFreeSessions
}

extension AlertMetric {
    func reading(in database: DatabaseReader, period: some ChartTimeScale) async throws -> MetricReading {
        let range = period.previousRange.lowerBound..<period.initialRange.upperBound

        switch self {
        case .eventCount(let name):
            let series = try await database.eventSeries(named: name, in: range)

            return MetricReading(
                points: series.flatMap { $0.chartPoints() },
                period: period
            )

        case .crashFreeSessions:
            async let sessions = database.sessionSeries(in: range)
            async let crashes = database.crashSeries(in: range)

            return try await MetricReading(
                sessions: sessions.flatMap { $0.chartPoints() },
                crashes: crashes.flatMap { $0.chartPoints() },
                period: period
            )
        }
    }

    func values(in database: DatabaseReader, range: Range<Date>) async throws -> [Double] {
        switch self {
        case .eventCount(let name):
            return try await database.eventSeries(named: name, in: range)
                .flatMap { $0.chartPoints() as [ChartPoint<Int>] }
                .bucket(in: range, component: .hour)
                .reversed()
                .map { Double($0.value) }

        case .crashFreeSessions:
            async let sessions = database.sessionSeries(in: range)
            async let crashes = database.crashSeries(in: range)

            return try await stabilityValues(
                sessions: sessions.flatMap { $0.chartPoints() },
                crashes: crashes.flatMap { $0.chartPoints() },
                in: range,
                component: .hour
            )
        }
    }
}

extension DatabaseReader {
    fileprivate func eventSeries(named name: String, in range: Range<Date>) async throws -> [MetricSeries] {
        try await series(
            matching: SeriesQuery(
                name: name,
                bucket: .hour,
                range: range
            )
        )
    }

    fileprivate func sessionSeries(in range: Range<Date>) async throws -> [MetricSeries] {
        try await series(
            matching: SeriesQuery(
                name: SessionEntry.recordType,
                bucket: .hour,
                source: .lifecycle,
                range: range
            )
        )
    }

    fileprivate func crashSeries(in range: Range<Date>) async throws -> [MetricSeries] {
        try await series(
            matching: SeriesQuery(
                name: CrashEntry.recordType,
                bucket: .hour,
                source: .lifecycle,
                range: range
            )
        )
    }
}
