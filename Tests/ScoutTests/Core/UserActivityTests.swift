//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

struct UserActivityTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Trigger") func trigger() async throws {
        let date = Date(iso8601String: "2025-01-01T00:00:00Z")

        try UserActivity.trigger(date: date, in: context)

        let request = UserActivity.fetchRequest()
        let activities = try context.fetch(request)

        let days = activities.days.map(\.dayCount)
        let weeks = activities.weeks.map(\.weekCount)
        let months = activities.months.map(\.monthCount)

        #expect(days == Array(repeating: 1, count: 1))
        #expect(weeks == Array(repeating: 1, count: 7))
        #expect(months == Array(repeating: 1, count: 31))
    }

    @Test("Trigger at next day") func triggerNextDay() async throws {
        try UserActivity.trigger(date: Date(iso8601String: "2025-01-01T00:00:00Z"), in: context)
        try UserActivity.trigger(date: Date(iso8601String: "2025-01-02T00:00:00Z"), in: context)

        let request = UserActivity.fetchRequest()
        let activities = try context.fetch(request)

        let days = activities.days.map(\.dayCount)
        let weeks = activities.weeks.map(\.weekCount)
        let months = activities.months.map(\.monthCount)

        #expect(days == Array(repeating: 1, count: 2))
        #expect(weeks == Array(repeating: 1, count: 8))
        #expect(months == Array(repeating: 1, count: 32))
    }

    @Test("Trigger skip one day") func triggerSkipDay() async throws {
        try UserActivity.trigger(date: Date(iso8601String: "2025-01-01T00:00:00Z"), in: context)
        try UserActivity.trigger(date: Date(iso8601String: "2025-01-03T00:00:00Z"), in: context)

        let request = UserActivity.fetchRequest()
        let activities = try context.fetch(request)

        let days = activities.days.map(\.dayCount)
        let weeks = activities.weeks.map(\.weekCount)
        let months = activities.months.map(\.monthCount)

        #expect(days == Array(repeating: 1, count: 2))
        #expect(weeks == Array(repeating: 1, count: 9))
        #expect(months == Array(repeating: 1, count: 33))
    }
}

extension [UserActivity] {
    fileprivate var days: [UserActivity] {
        filter { $0.period == ActivityPeriod.daily.rawValue }
    }

    fileprivate var weeks: [UserActivity] {
        filter { $0.period == ActivityPeriod.weekly.rawValue }
    }

    fileprivate var months: [UserActivity] {
        filter { $0.period == ActivityPeriod.monthly.rawValue }
    }
}
