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
@Suite("SessionObject")
struct SessionObjectTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let week = Date(timeIntervalSince1970: 1_724_457_600).startOfWeek
    let date1 = Date(timeIntervalSince1970: 1_724_457_800)  // +200s
    let date2 = Date(timeIntervalSince1970: 1_724_458_000)  // +400s

    @Test("group(in:) returns correct SyncGroup for matching unsynced sessions")
    func testGroupIn() throws {
        SessionObject.stub(date: date1, synced: false, in: context)
        SessionObject.stub(date: date2, synced: false, in: context)
        SessionObject.stub(date: date2, synced: true, in: context)

        let group = try #require(try SessionObject.group(in: context))

        #expect(group.batch.count == 2)
        #expect(group.name == "Session")
        #expect(group.recordType == "DateIntMatrix")
        #expect(group.date == week)
        #expect(group.batch.allSatisfy { !$0.isSynced && $0.week == week })
    }

    @Test("parse(of:) produces correct Cell<Int> counts by date")
    func testParseOf() throws {
        let batch: [SessionObject] = [
            .stub(date: week, synced: false, in: context),
            .stub(date: week, synced: false, in: context),
            .stub(date: week.addingHour(), synced: false, in: context),
        ]

        let cells = SessionObject.parse(of: batch)

        #expect(cells.sorted() == [
            Cell(row: 1, column: 0, value: 2),
            Cell(row: 1, column: 1, value: 1),
        ])
    }
}
