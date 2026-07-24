//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

enum DemoCorpus {
    static let shared = make()

    struct Corpus {
        var records: [Record]
        var samples: [DemoSample]
        var activity: [ActivityPoint]
        var retention: [RetentionCohort]
    }

    static func make(now: Date = Date()) -> Corpus {
        let clock = DemoClock(now: now)
        let scenario = DemoScenario(clock: clock)
        let incidents = DemoIncidents(scenario: scenario)
        let events = DemoEvents(scenario: scenario)
        let releases = DemoReleases(scenario: scenario, incidents: incidents)
        let metrics = DemoMetrics(clock: clock)
        let activity = DemoActivity(scenario: scenario)

        return Corpus(
            records: scenario.records + incidents.records + events.records,
            samples: releases.samples + events.samples + metrics.samples,
            activity: activity.points,
            retention: activity.cohorts
        )
    }
}
