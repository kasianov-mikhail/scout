//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

struct EventQueryChipsTests {
    @Test("Default query has no chips") func defaultQuery() {
        #expect(EventQuery().chips.isEmpty)
    }

    @Test("Levels chip lists selected levels by severity") func levelsChip() {
        let chips = EventQuery(levels: [.critical, .error]).chips

        #expect(chips == [EventQuery.Chip(kind: .levels, label: "Error, Critical")])
    }

    // UTC-midnight range bounds, matching how FilterDraft builds query dates.
    let start = Date(timeIntervalSinceReferenceDate: 0)

    @Test("Date chip labels the range") func dateChip() {
        let chips = EventQuery(dates: start..<start.addingDay(2)).chips

        #expect(chips == [EventQuery.Chip(kind: .dates, label: "1 Jan – 2 Jan")])
    }

    @Test("Single-day date chip labels one day") func singleDayChip() {
        let chips = EventQuery(dates: start..<start.addingDay()).chips

        #expect(chips == [EventQuery.Chip(kind: .dates, label: "1 Jan")])
    }

    @Test("Session chip shows a short identifier") func sessionChip() {
        let sessionID = UUID(uuidString: "ABCDEF12-3456-7890-ABCD-EF1234567890")!
        let chips = EventQuery(sessionID: sessionID).chips

        #expect(chips == [EventQuery.Chip(kind: .session, label: "Session ABCDEF12")])
    }

    @Test("Device chip shows a short identifier") func deviceChip() {
        let deviceID = UUID(uuidString: "ABCDEF12-3456-7890-ABCD-EF1234567890")!
        let chips = EventQuery(deviceID: deviceID).chips

        #expect(chips == [EventQuery.Chip(kind: .device, label: "Device ABCDEF12")])
    }

    @Test("Chips combine in a stable order") func combined() {
        let start = Date(timeIntervalSinceReferenceDate: 0)
        let query = EventQuery(levels: [.error], sessionID: UUID(), deviceID: UUID(), dates: start..<start.addingDay())

        #expect(query.chips.map(\.kind) == [.levels, .dates, .session, .device])
    }

    @Test("Removing a chip clears its criteria") func remove() {
        let start = Date(timeIntervalSinceReferenceDate: 0)
        var query = EventQuery(levels: [.error], sessionID: UUID(), deviceID: UUID(), dates: start..<start.addingDay())

        query.remove(.levels)
        #expect(query.levels == EventQuery.allLevels)

        query.remove(.dates)
        #expect(query.dates == nil)

        query.remove(.session)
        #expect(query.sessionID == nil)

        query.remove(.device)
        #expect(query.deviceID == nil)

        #expect(query.chips.isEmpty)
    }
}
