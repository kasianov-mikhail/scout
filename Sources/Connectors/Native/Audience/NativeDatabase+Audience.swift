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

extension NativeDatabase: AudienceReader {
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        let store = try await resolve()
        let span = range.lookback..<range.upperBound

        async let gaps = store.query(VisitGapEntry.recordType).series(
            metric: .sum,
            group: "gap",
            in: span
        )
        async let versions = store.query(VisitGapEntry.recordType).series(
            metric: .sum,
            group: "app_version",
            in: span
        )
        async let sessions = store.query(SessionEntry.recordType).series(
            metric: .sum,
            group: CatalogEntry.lifecycleKey,
            in: span
        )

        let fold = try await VisitGapFold(gaps: gaps, versions: versions, sessions: sessions)

        var points = fold.points(in: range)
        for unstamped in fold.unstampedSpans(in: range) {
            points += try await store.deviceActivity(in: unstamped)
        }
        return points.sorted { $0.date < $1.date }
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        let store = try await resolve()

        let marks = try await store.query(RetentionMarkEntry.recordType).series(
            metric: .sum,
            group: CatalogEntry.retentionKey,
            in: range
        )

        return [RetentionCohort](tallies: marks.compactMap(RetentionTally.init), now: Date())
    }
}

extension EntityStore {
    fileprivate func deviceActivity(in range: Range<Date>) async throws -> [ActivityPoint] {
        let visits = try await query(VisitEntry.recordType).series(
            metric: .sum,
            group: "device_id",
            in: range.lookback..<range.upperBound
        )

        return ActivityPoint.points(
            visits: visits.filter { !$0.group.isEmpty }.map { DatedID(date: $0.date, id: $0.group) },
            in: range
        )
    }
}

extension Range<Date> {
    fileprivate var lookback: Date {
        lowerBound.addingTimeInterval(-30 * .day).startOfDay
    }
}
