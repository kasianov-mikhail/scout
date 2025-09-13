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
@Suite("EventObject")
struct EventObjectTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(timeIntervalSince1970: 1_724_457_600).startOfWeek

    @Test("group(in:) returns correct SyncGroup for matching unsynced events")
    func testGroupIn() throws {
        let name = "test-event"

        for _ in 0..<3 {
            EventObject.stub(name: name, date: date, synced: false, in: context)
        }

        EventObject.stub(name: name, date: date, synced: true, in: context)

        let group = try #require(try EventObject.group(in: context))

        #expect(group.matrix.name == name)
        #expect(group.matrix.date == date)
        #expect(group.batch.count == 3)
        #expect(group.batch.allSatisfy { $0.isSynced == false })
    }

    @Test("parse(of:) produces correct Cell<Int> counts by hour")
    func testParseOf() throws {
        let batch: [EventObject] = [
            .stub(name: "name", date: date, in: context),
            .stub(name: "name", date: date, in: context),
            .stub(name: "name", date: date.addingHour(), in: context)
        ]

        let cells = EventObject.parse(of: batch)

        let counts = cells.map(\.value)
        #expect(counts.contains(2))
        #expect(counts.contains(1))
        #expect(counts.reduce(0, +) == 3)
    }
}
