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

    @Test("parse(of:) produces correct GridCell<Int> counts by date")
    func testParseOf() throws {
        let batch: [SessionObject] = [
            .stub(date: week, synced: false, in: context),
            .stub(date: week, synced: false, in: context),
            .stub(date: week.addingHour(), synced: false, in: context),
        ]

        let cells = try SessionObject.parse(of: batch)

        #expect(
            cells.sorted() == [
                GridCell(row: 1, column: 0, value: 2),
                GridCell(row: 1, column: 1, value: 1),
            ])
    }

    @Test("launch(in:) returns launch matching launchID")
    func testLaunch() throws {
        let session = SessionObject.stub(date: week, in: context)
        let launchID = session.launchID

        let launch = LaunchObject.stub(date: week, in: context)
        launch.launchID = launchID

        // Launch with different launchID
        LaunchObject.stub(date: week, in: context).launchID = UUID()

        try context.save()

        let result = try session.launch(in: context)
        #expect(result?.launchID == launchID)
    }
}
