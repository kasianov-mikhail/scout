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

        async let installs = store.records(
            entity: InstallEntry.recordType,
            dateField: "date",
            fields: ["date", "install_id", "device_id"],
            in: range
        )
        async let sessions = store.query(SessionEntry.recordType).series(
            metric: .sum,
            group: "install_id",
            in: range
        )
        async let systems = store.query(SessionEntry.recordType).series(
            metric: .sum,
            group: CatalogEntry.deviceSystem,
            in: range
        )
        async let crashes = store.datedIDs(
            entity: CrashEntry.recordType,
            dateField: "date",
            idField: "install_id",
            in: range
        )
        async let hangs = store.datedIDs(
            entity: HangEntry.recordType,
            dateField: "date",
            idField: "install_id",
            in: range
        )

        let fold = try await RetentionFold(
            installs: installs,
            sessions: sessions,
            systems: systems
        )

        return try await RetentionCohort.cohorts(
            installs: fold.installIDs,
            sessions: fold.installSessions,
            crashes: crashes,
            hangs: hangs,
            range: range,
            now: Date()
        )
    }
}
