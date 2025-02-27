//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData
import Testing

@testable import Scout

struct SyncableTests {
    let context = NSManagedObjectContext.inMemoryContext()

    let date: Date
    let nextHour: Date
    let nextDay: Date

    init() {
        let components = DateComponents(
            year: 2025,
            month: 1,
            day: 1,
            hour: 10
        )

        date = Calendar.UTC.date(from: components)!
        nextHour = date.addingTimeInterval(3600)
        nextDay = date.addingTimeInterval(86400)
    }

    @Test("EventModel grouping") func testEventModelGrouping() throws {
        let entity = NSEntityDescription.entity(forEntityName: "EventObject", in: context)!
        let event1 = EventObject(entity: entity, insertInto: context)
        event1.name = "event_name"
        event1.date = date

        let event2 = EventObject(entity: entity, insertInto: context)
        event2.name = "event_name"
        event2.date = nextHour

        let event3 = EventObject(entity: entity, insertInto: context)
        event3.name = "event_name"
        event3.date = nextHour
        event3.isSynced = true

        let group = try EventObject.group(in: context)

        #expect(group?.name == "event_name")
        #expect(group?.date == event1.week)
        #expect(group?.objects.count == 2)
        #expect(group?.fields["cell_4_10"] == 1)
        #expect(group?.fields["cell_4_11"] == 1)
    }

    @Test("Session grouping") func testSessionGrouping() throws {
        let entity = NSEntityDescription.entity(forEntityName: "SessionObject", in: context)!
        let session1 = SessionObject(entity: entity, insertInto: context)
        session1.date = date

        let session2 = SessionObject(entity: entity, insertInto: context)
        session2.date = nextHour

        let session3 = SessionObject(entity: entity, insertInto: context)
        session3.endDate = nextHour
        session3.isSynced = true

        let group = try SessionObject.group(in: context)

        #expect(group?.name == "Session")
        #expect(group?.date == session1.week)
        #expect(group?.objects.count == 2)
        #expect(group?.fields["cell_4_10"] == 1)
        #expect(group?.fields["cell_4_11"] == 1)
    }

    @Test("UserActivity grouping") func testUserActivityGrouping() throws {
        let entity = NSEntityDescription.entity(forEntityName: "UserActivity", in: context)!
        let activity1 = UserActivity(entity: entity, insertInto: context)
        activity1.date = date
        activity1.period = ActivityPeriod.daily.rawValue
        activity1.dayCount = 1

        let activity2 = UserActivity(entity: entity, insertInto: context)
        activity2.date = nextDay
        activity2.period = ActivityPeriod.weekly.rawValue
        activity2.weekCount = 2

        let activity3 = UserActivity(entity: entity, insertInto: context)
        activity3.date = nextDay
        activity3.period = ActivityPeriod.weekly.rawValue
        activity3.weekCount = 2
        activity3.isSynced = true

        let group = try UserActivity.group(in: context)

        #expect(group?.name == "ActiveUser")
        #expect(group?.date == activity1.month)
        #expect(group?.objects.count == 2)
        #expect(group?.fields["cell_d_01"] == 1)
        #expect(group?.fields["cell_w_02"] == 2)
    }
}
