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
@Suite("UserActivityObject+Monitor")
struct UserActivityObjectMontitorTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Trigger") func trigger() async throws {
        try UserActivityObject.trigger(date: Date(year: 2025, month: 1, day: 1), in: context)

        let request = NSFetchRequest<UserActivityObject>(entityName: "UserActivityObject")
        let activities = try context.fetch(request)

        let days = activities.days.map(\.dayCount)
        let weeks = activities.weeks.map(\.weekCount)
        let months = activities.months.map(\.monthCount)

        #expect(days == Array(repeating: 1, count: 1))
        #expect(weeks == Array(repeating: 1, count: 7))
        #expect(months == Array(repeating: 1, count: 31))
    }

    @Test("Trigger at next day") func triggerNextDay() async throws {
        try UserActivityObject.trigger(date: Date(year: 2025, month: 1, day: 1), in: context)
        try UserActivityObject.trigger(date: Date(year: 2025, month: 1, day: 2), in: context)

        let request = NSFetchRequest<UserActivityObject>(entityName: "UserActivityObject")
        let activities = try context.fetch(request)

        let days = activities.days.map(\.dayCount)
        let weeks = activities.weeks.map(\.weekCount)
        let months = activities.months.map(\.monthCount)

        #expect(days == Array(repeating: 1, count: 2))
        #expect(weeks == Array(repeating: 1, count: 8))
        #expect(months == Array(repeating: 1, count: 32))
    }

    @Test("Trigger skip one day") func triggerSkipDay() async throws {
        try UserActivityObject.trigger(date: Date(year: 2025, month: 1, day: 1), in: context)
        try UserActivityObject.trigger(date: Date(year: 2025, month: 1, day: 3), in: context)

        let request = NSFetchRequest<UserActivityObject>(entityName: "UserActivityObject")
        let activities = try context.fetch(request)

        let days = activities.days.map(\.dayCount)
        let weeks = activities.weeks.map(\.weekCount)
        let months = activities.months.map(\.monthCount)

        #expect(days == Array(repeating: 1, count: 2))
        #expect(weeks == Array(repeating: 1, count: 9))
        #expect(months == Array(repeating: 1, count: 33))
    }
}

extension [UserActivityObject] {
    fileprivate var days: [UserActivityObject] {
        filter { $0.period == ActivityPeriod.daily.rawValue }
    }

    fileprivate var weeks: [UserActivityObject] {
        filter { $0.period == ActivityPeriod.weekly.rawValue }
    }

    fileprivate var months: [UserActivityObject] {
        filter { $0.period == ActivityPeriod.monthly.rawValue }
    }
}
