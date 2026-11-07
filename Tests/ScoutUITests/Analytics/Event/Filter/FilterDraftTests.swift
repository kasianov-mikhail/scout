//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftUI
import Testing

@testable import ScoutUI

@MainActor
struct FilterDraftTests {
    final class Box {
        var query = EventQuery()
    }

    let box = Box()
    let today = Date(timeIntervalSinceReferenceDate: 86400 * 100)

    var draft: FilterDraft {
        FilterDraft(
            query: Binding(get: { [box] in box.query }, set: { [box] in box.query = $0 }),
            today: today
        )
    }

    @Test("Toggle flips level selection") func toggle() {
        let draft = draft

        #expect(draft.isSelected(.error) == false)

        draft.toggle(.error)
        #expect(draft.isSelected(.error))

        draft.toggle(.error)
        #expect(draft.isSelected(.error) == false)
    }

    @Test("Apply is disabled while the draft matches the query") func applyDisabled() {
        #expect(draft.isApplyEnabled == false)
    }

    @Test("An empty level selection applies every level") func emptyLevels() {
        box.query = EventQuery(levels: [.error])

        let draft = draft
        draft.levels = []

        #expect(draft.isApplyEnabled)

        draft.apply()
        #expect(box.query.levels == EventQuery.allLevels)
    }

    @Test("Apply writes the draft back to the query") func apply() {
        let draft = draft
        draft.toggle(.trace)

        #expect(draft.isApplyEnabled)

        draft.apply()
        #expect(box.query.levels == [.trace])
    }

    @Test("Session field maps to the query identifier") func session() {
        let sessionID = UUID()
        let draft = draft
        draft.sessionText = " \(sessionID.uuidString) "

        #expect(draft.isSessionValid)

        draft.apply()
        #expect(box.query.sessionID == sessionID)
    }

    @Test("Invalid identifier text disables apply") func invalidSession() {
        let draft = draft
        draft.sessionText = "not-a-uuid"

        #expect(draft.isSessionValid == false)
        #expect(draft.isApplyEnabled == false)
    }

    @Test("Device field maps to the query identifier") func device() {
        let deviceID = UUID()
        let draft = draft
        draft.deviceText = " \(deviceID.uuidString) "

        #expect(draft.isDeviceValid)

        draft.apply()
        #expect(box.query.deviceID == deviceID)
    }

    @Test("Invalid device text disables apply") func invalidDevice() {
        let draft = draft
        draft.deviceText = "not-a-uuid"

        #expect(draft.isDeviceValid == false)
        #expect(draft.isApplyEnabled == false)
    }

    @Test("Period applies day-aligned bounds") func period() {
        let draft = draft
        draft.period = .week

        draft.apply()
        #expect(box.query.dates == today.startOfDay.addingDay(-6)..<today.startOfDay.addingDay())
    }

    @Test("Today covers the current day") func todayPeriod() {
        let draft = draft
        draft.period = .today

        draft.apply()
        #expect(box.query.dates == today.startOfDay..<today.startOfDay.addingDay())
    }

    @Test("Draft starts from the applied query") func initialState() {
        let dates = today.startOfDay.addingDay(-6)..<today.startOfDay.addingDay()
        box.query = EventQuery(levels: [.error], sessionID: UUID(), dates: dates)

        let draft = draft

        #expect(draft.levels == [.error])
        #expect(draft.period == .week)
        #expect(draft.sessionText == box.query.sessionID?.uuidString)
        #expect(draft.isApplyEnabled == false)
    }

    @Test("Draft starts with no levels when the query has none set") func allLevelsState() {
        box.query = EventQuery()

        #expect(draft.levels.isEmpty)
        #expect(draft.period == .any)
    }

    @Test("A custom date range keeps its bounds") func customRange() {
        let dates = today.startOfDay.addingDay(-3)..<today.startOfDay
        box.query = EventQuery(dates: dates)

        let draft = draft

        #expect(draft.period == .custom(dates))
    }

    @Test("A custom date range survives apply") func customRangeApply() {
        let dates = today.startOfDay.addingDay(-3)..<today.startOfDay
        box.query = EventQuery(dates: dates)

        let draft = draft
        draft.toggle(.error)

        #expect(draft.isApplyEnabled)

        draft.apply()
        #expect(box.query.dates == dates)
    }

    @Test("Reset restores the defaults") func reset() {
        let draft = draft
        draft.toggle(.error)
        draft.period = .month
        draft.sessionText = UUID().uuidString
        draft.deviceText = UUID().uuidString

        draft.reset()
        #expect(draft.levels.isEmpty)
        #expect(draft.period == .any)
        #expect(draft.sessionText.isEmpty)
        #expect(draft.deviceText.isEmpty)
    }

    @Test("Reset on a filtered query enables apply and clears it") func resetThenApply() {
        let dates = today.startOfDay.addingDay(-6)..<today.startOfDay.addingDay()
        box.query = EventQuery(levels: [.error], sessionID: UUID(), dates: dates)

        let draft = draft
        draft.reset()

        #expect(draft.isApplyEnabled)

        draft.apply()
        #expect(box.query == EventQuery())
    }
}
