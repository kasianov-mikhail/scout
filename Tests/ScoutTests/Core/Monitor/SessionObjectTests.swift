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
