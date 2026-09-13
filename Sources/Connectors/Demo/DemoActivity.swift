//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DemoActivity {
    let points: [ActivityPoint]
    let cohorts: [RetentionCohort]

    init(scenario: DemoScenario, incidents: DemoIncidents) {
        let range = scenario.clock.foldRange

        let visits = scenario.sessions.map {
            ActivityVisit(date: $0.start, user: $0.device.id.uuidString)
        }
        points = ActivityPoint.points(visits: visits, in: range)

        cohorts = [RetentionCohort](
            installs: scenario.installs.map { DatedID(date: $0.date, id: $0.id.uuidString) },
            sessions: scenario.sessions.map { InstallSession(install: $0.install.id.uuidString, date: $0.start, os: $0.device.os) },
            crashes: incidents.crashes.dated,
            hangs: incidents.hangs.dated,
            range: range,
            now: scenario.clock.now
        )
    }
}

extension [DemoIncidents.Point] {
    fileprivate var dated: [DatedID] {
        map { DatedID(date: $0.date, id: $0.installID.uuidString) }
    }
}
