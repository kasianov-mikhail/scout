//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

@MainActor
@Suite("ActivityEntry+Monitor")
struct ActivityEntryMonitorTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let sessionID = UUID()

    @Test("Trigger") func trigger() async throws {
        try ActivityEntry.Trigger(session: Protected(sessionID), date: Date(year: 2025, month: 1, day: 1)).execute(
            in: context)

        let activities = try context.fetchAll(ActivityEntry.self)

        let days = activities.days.map(\.dayCount)
        let weeks = activities.weeks.map(\.weekCount)
        let months = activities.months.map(\.monthCount)

        #expect(days == Array(repeating: 1, count: 1))
        #expect(weeks == Array(repeating: 1, count: 7))
        #expect(months == Array(repeating: 1, count: 31))
    }

    @Test("Trigger at next day") func triggerNextDay() async throws {
        try ActivityEntry.Trigger(session: Protected(sessionID), date: Date(year: 2025, month: 1, day: 1)).execute(
            in: context)
        try ActivityEntry.Trigger(session: Protected(sessionID), date: Date(year: 2025, month: 1, day: 2)).execute(
            in: context)

        let activities = try context.fetchAll(ActivityEntry.self)

        let days = activities.days.map(\.dayCount)
        let weeks = activities.weeks.map(\.weekCount)
        let months = activities.months.map(\.monthCount)

        #expect(days == Array(repeating: 1, count: 2))
        #expect(weeks == Array(repeating: 1, count: 8))
        #expect(months == Array(repeating: 1, count: 32))
    }

    @Test("Trigger skip one day") func triggerSkipDay() async throws {
        try ActivityEntry.Trigger(session: Protected(sessionID), date: Date(year: 2025, month: 1, day: 1)).execute(
            in: context)
        try ActivityEntry.Trigger(session: Protected(sessionID), date: Date(year: 2025, month: 1, day: 3)).execute(
            in: context)

        let activities = try context.fetchAll(ActivityEntry.self)

        let days = activities.days.map(\.dayCount)
        let weeks = activities.weeks.map(\.weekCount)
        let months = activities.months.map(\.monthCount)

        #expect(days == Array(repeating: 1, count: 2))
        #expect(weeks == Array(repeating: 1, count: 9))
        #expect(months == Array(repeating: 1, count: 33))
    }
}

extension [ActivityEntry] {
    fileprivate var days: [ActivityEntry] {
        filter { $0.period == ActivityPeriod.daily.rawValue }
    }

    fileprivate var weeks: [ActivityEntry] {
        filter { $0.period == ActivityPeriod.weekly.rawValue }
    }

    fileprivate var months: [ActivityEntry] {
        filter { $0.period == ActivityPeriod.monthly.rawValue }
    }
}
