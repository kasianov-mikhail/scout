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
        case .eventCount:
            return MetricReading(points: try await eventPoints(in: database, range: range), period: period)
        case .crashFreeSessions:
            let (sessions, crashes) = try await lifecyclePoints(in: database, range: range)
            return MetricReading(sessions: sessions, crashes: crashes, period: period)
        }
    }

    func values(in database: DatabaseReader, range: Range<Date>) async throws -> [Double] {
        switch self {
        case .eventCount:
            return try await eventPoints(in: database, range: range)
                .bucket(in: range, component: .hour)
                .reversed()
                .map { Double($0.count) }

        case .crashFreeSessions:
            let (sessions, crashes) = try await lifecyclePoints(in: database, range: range)
            return MetricReading.stabilities(sessions: sessions, crashes: crashes, in: range, component: .hour)
        }
    }

    private func eventPoints(in database: DatabaseReader, range: Range<Date>) async throws -> [ChartPoint<Int>] {
        guard case .eventCount(let name) = self else { return [] }

        let series = try await database.series(
            matching: SeriesQuery(name: name, bucket: .hour, range: range)
        )
        return series.flatMap { $0.chartPoints() }
    }

    private func lifecyclePoints(in database: DatabaseReader, range: Range<Date>) async throws -> (
        sessions: [ChartPoint<Int>], crashes: [ChartPoint<Int>]
    ) {
        async let sessions = database.series(
            matching: SeriesQuery(name: SessionEntry.recordType, bucket: .hour, source: .lifecycle, range: range)
        )
        async let crashes = database.series(
            matching: SeriesQuery(name: CrashEntry.recordType, bucket: .hour, source: .lifecycle, range: range)
        )

        return (
            sessions: try await sessions.flatMap { $0.chartPoints() },
            crashes: try await crashes.flatMap { $0.chartPoints() }
        )
    }
}
