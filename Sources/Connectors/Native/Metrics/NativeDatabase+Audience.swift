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
        let window = lookback..<range.upperBound

        async let markers = store.datedIDs(
            entity: VisitEntry.recordType,
            dateField: "date",
            idField: "device_id",
            in: window
        )
        async let sessions = store.datedIDs(
            entity: SessionEntry.recordType,
            dateField: "start_date",
            idField: "device_id",
            in: window
        )

        return try await ActivityPoint.points(visits: markers + sessions, in: range)
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        let store = try await resolve()

        async let installs = store.datedIDs(
            entity: InstallEntry.recordType,
            dateField: "date",
            idField: "install_id",
            in: range
        )
        async let sessions = store.records(
            entity: SessionEntry.recordType,
            dateField: "start_date",
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

        return try await RetentionCohort.cohorts(
            installs: installs,
            sessions: sessions.compactMap { record -> InstallSession? in
                let install: String? = record["install_id"]
                let start: Date? = record["start_date"]
                guard let install, let start else {
                    return nil
                }
                return InstallSession(install: install, date: start, os: record["os_version"])
            },
            crashes: crashes,
            hangs: hangs,
            range: range,
            now: Date()
        )
    }
}
