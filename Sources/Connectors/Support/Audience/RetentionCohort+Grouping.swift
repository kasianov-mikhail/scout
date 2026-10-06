//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension RetentionCohort {
    package static func cohorts(installs: [DatedID], sessions: [InstallSession], crashes: [DatedID], hangs: [DatedID], range: Range<Date>, now: Date) -> [RetentionCohort] {
        let sessions = Dictionary(grouping: sessions, by: \.install)
        let names = sessions.compactMapValues(\.osMajor)
        let sessionDays = sessions.map { InstallDates(install: $0.key, dates: $0.value.days) }
        let crashes = InstallDates.grouped(crashes)
        let hangs = InstallDates.grouped(hangs)
        let horizon = (dayOffsets.last ?? 0) + 1

        return InstallGroup(installs).days(in: range).byWeek.map { week, installs in
            RetentionCohort(
                week: week,
                installs: installs,
                segments: installs.grouped(by: names),
                sessionDays: sessionDays,
                crashes: crashes,
                hangs: hangs,
                horizon: horizon,
                now: now
            )
        }
        .sorted()
    }
}

extension RetentionCohort {
    fileprivate init(week: Date, installs: InstallGroup, segments: [String: InstallGroup], sessionDays: [InstallDates], crashes: [InstallDates], hangs: [InstallDates], horizon: Int, now: Date) {
        self.init(
            id: week,
            size: installs.count,
            retention: installs.retention(week: week, sessionDays: sessionDays, now: now),
            segments: segments.map { name, installs in
                RetentionSegment(
                    name: name,
                    installs: installs,
                    week: week,
                    sessionDays: sessionDays,
                    crashes: crashes,
                    hangs: hangs,
                    horizon: horizon,
                    now: now
                )
            }
            .sorted()
        )
    }
}

extension RetentionSegment {
    fileprivate init(name: String, installs: InstallGroup, week: Date, sessionDays: [InstallDates], crashes: [InstallDates], hangs: [InstallDates], horizon: Int, now: Date) {
        self.init(
            name: name,
            size: installs.count,
            retention: installs.retention(week: week, sessionDays: sessionDays, now: now),
            crashes: installs.affected(by: crashes, within: horizon),
            hangs: installs.affected(by: hangs, within: horizon)
        )
    }
}
