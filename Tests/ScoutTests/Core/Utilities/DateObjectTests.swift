//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

@MainActor
@Suite("DateObject")
struct DateObjectTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("Setting date computes all derived properties")
    func testDateSetterComputesDerived() throws {
        let entity = NSEntityDescription.entity(forEntityName: "SessionObject", in: context)!
        let object = SessionObject(entity: entity, insertInto: context)

        let date = Date(timeIntervalSince1970: 1_700_000_000)  // 2023-11-14 22:13:20 UTC
        object.date = date

        #expect(object.datePrimitive == date)
        #expect(object.hour == date.startOfHour)
        #expect(object.day == date.startOfDay)
        #expect(object.week == date.startOfWeek)
        #expect(object.month == date.startOfMonth)
    }

    @Test("Setting date to nil clears derived properties")
    func testDateSetterNil() throws {
        let entity = NSEntityDescription.entity(forEntityName: "SessionObject", in: context)!
        let object = SessionObject(entity: entity, insertInto: context)

        object.date = Date()
        object.date = nil

        #expect(object.datePrimitive == nil)
        #expect(object.hour == nil)
        #expect(object.day == nil)
        #expect(object.week == nil)
        #expect(object.month == nil)
    }

    @Test("Derived properties are consistent across date changes")
    func testDateSetterConsistency() throws {
        let entity = NSEntityDescription.entity(forEntityName: "SessionObject", in: context)!
        let object = SessionObject(entity: entity, insertInto: context)

        let date1 = Date(timeIntervalSince1970: 1_700_000_000)
        let date2 = Date(timeIntervalSince1970: 1_710_000_000)

        object.date = date1
        let hour1 = object.hour

        object.date = date2
        let hour2 = object.hour

        #expect(hour1 == date1.startOfHour)
        #expect(hour2 == date2.startOfHour)
        #expect(hour1 != hour2)
    }
}
