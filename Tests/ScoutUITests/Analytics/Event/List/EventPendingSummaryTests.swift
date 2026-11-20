//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import Testing

@testable import ScoutUI

@Suite("EventPendingSummary")
struct EventPendingSummaryTests {
    @Test("Groups the held events by severity, most severe first")
    func groupsBySeverity() {
        let summary = EventPendingSummary(events: events([.critical, .error, .error, .warning, .notice, .notice, .notice, .notice]), limit: 4)

        #expect(summary.groups.map(\.level) == [.critical, .error, .warning, .notice])
        #expect(summary.groups.map(\.count) == [1, 2, 1, 4])
        #expect(summary.total == 8)
    }

    @Test("Cuts the quietest levels past the limit")
    func cutsQuietestLevels() {
        let summary = EventPendingSummary(events: events([.critical, .trace, .debug, .info, .notice, .warning]), limit: 4)

        #expect(summary.groups.map(\.level) == [.critical, .warning, .notice, .info])
        #expect(summary.total == 6)
    }

    @Test("An event without a level counts as info")
    func missingLevelCountsAsInfo() {
        let summary = EventPendingSummary(events: events([nil, nil, .info]), limit: 4)

        #expect(summary.groups.map(\.level) == [.info])
        #expect(summary.groups.map(\.count) == [3])
    }

    @Test("No held events leave no groups")
    func noEvents() {
        let summary = EventPendingSummary(events: [], limit: 4)

        #expect(summary.groups.isEmpty)
        #expect(summary.total == 0)
        #expect(summary.isEmpty)
    }

    private func events(_ levels: [EventLevel?]) -> [Event] {
        levels.map { Event.sample("login", at: Date(timeIntervalSince1970: 0), level: $0) }
    }
}
