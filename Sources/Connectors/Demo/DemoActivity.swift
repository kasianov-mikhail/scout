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

    init(scenario: DemoScenario) {
        let range = scenario.clock.foldRange

        let visits = scenario.sessions.map {
            ActivityVisit(date: $0.start, user: $0.device.id.uuidString)
        }
        points = ActivityPoint.points(visits: visits, in: range)

        var installDays: [String: Date] = [:]
        for install in scenario.installs where range.contains(install.date) {
            installDays[install.id.uuidString] = install.date
        }

        var sessionDays: [String: Set<Date>] = [:]
        for session in scenario.sessions {
            sessionDays[session.install.id.uuidString, default: []].insert(session.start.startOfDay)
        }

        cohorts = RetentionCohort.build(
            installDays: installDays,
            sessionDays: sessionDays,
            in: range,
            asOf: scenario.clock.now
        )
    }
}
