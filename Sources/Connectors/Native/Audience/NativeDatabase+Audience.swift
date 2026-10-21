//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorSupport
import Foundation
import Scout

extension NativeDatabase: AudienceReader {
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        let store = try await resolve()
        let lookback = range.lowerBound.addingTimeInterval(-30 * .day).startOfDay

        let visits = try await store.query(VisitEntry.recordType).series(
            metric: .sum,
            group: "device_id",
            in: lookback..<range.upperBound
        )

        return ActivityPoint.points(
            visits: visits.filter { !$0.group.isEmpty }.map { DatedID(date: $0.date, id: $0.group) },
            in: range
        )
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
