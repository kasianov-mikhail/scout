//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftUI
import Testing

@testable import Scout
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

        #expect(draft.isSelected(.error))

        draft.toggle(.error)
        #expect(draft.isSelected(.error) == false)

        draft.toggle(.error)
        #expect(draft.isSelected(.error))
    }

    @Test("Apply is disabled while the draft matches the query") func applyDisabled() {
        #expect(draft.isApplyEnabled == false)
    }

    @Test("Apply is disabled when no levels are selected") func applyNeedsLevels() {
        let draft = draft
        draft.levels = []

        #expect(draft.isApplyEnabled == false)
    }

    @Test("Apply writes the draft back to the query") func apply() {
        let draft = draft
        draft.toggle(.trace)

        #expect(draft.isApplyEnabled)

        draft.apply()
        #expect(box.query.levels == EventQuery.allLevels.subtracting([.trace]))
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

    @Test("Date range applies day-aligned bounds") func dateRange() {
        let draft = draft
        draft.isDateRangeEnabled = true

        draft.apply()
        #expect(box.query.dates == today.startOfDay.addingDay(-6)..<today.startOfDay.addingDay())
    }

    @Test("Inverted date range disables apply") func invertedRange() {
        let draft = draft
        draft.isDateRangeEnabled = true
        draft.endDate = draft.startDate.addingDay(-1)

        #expect(draft.isDateRangeValid == false)
        #expect(draft.isApplyEnabled == false)
    }

    @Test("Draft starts from the applied query") func initialState() {
        let dates = today.startOfDay.addingDay(-3)..<today.startOfDay
        box.query = EventQuery(levels: [.error], sessionID: UUID(), dates: dates)

        let draft = draft

        #expect(draft.levels == [.error])
        #expect(draft.isDateRangeEnabled)
        #expect(draft.startDate == dates.lowerBound)
        #expect(draft.endDate == dates.upperBound.addingDay(-1))
        #expect(draft.sessionText == box.query.sessionID?.uuidString)
        #expect(draft.isApplyEnabled == false)
    }

    @Test("Reset restores the defaults") func reset() {
        let draft = draft
        draft.toggle(.error)
        draft.isDateRangeEnabled = true
        draft.startDate = today.startOfDay.addingDay(-30)
        draft.sessionText = UUID().uuidString
        draft.deviceText = UUID().uuidString

        #expect(draft.isResetEnabled)

        draft.reset()
        #expect(draft.levels == EventQuery.allLevels)
        #expect(draft.isDateRangeEnabled == false)
        #expect(draft.startDate == today.startOfDay.addingDay(-6))
        #expect(draft.sessionText.isEmpty)
        #expect(draft.deviceText.isEmpty)
        #expect(draft.isResetEnabled == false)
    }

    @Test("Reset on a filtered query enables apply and clears it") func resetThenApply() {
        box.query = EventQuery(
            levels: [.error], sessionID: UUID(), dates: today.startOfDay.addingDay(-3)..<today.startOfDay)

        let draft = draft
        draft.reset()

        #expect(draft.isApplyEnabled)

        draft.apply()
        #expect(box.query == EventQuery())
    }
}
