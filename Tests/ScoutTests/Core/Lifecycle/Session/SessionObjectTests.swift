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
    let week = TestDate.reference.startOfWeek

    @Test("matrix(of:) produces correct GridCell<Int> counts by date")
    func testMatrixOf() throws {
        let batch: [SessionObject] = [
            .stub(date: week, synced: false, in: context),
            .stub(date: week, synced: false, in: context),
            .stub(date: week.addingHour(), synced: false, in: context),
        ]

        let matrix = try SessionObject.matrix(of: batch)

        #expect(
            matrix.cells.sorted() == [
                GridCell(row: 1, column: 0, value: 2),
                GridCell(row: 1, column: 1, value: 1),
            ])
    }

    @Test("matrix(of:) carries the app version, leaving category untouched")
    func testMatrixCarriesVersion() throws {
        let batch: [SessionObject] = [
            .stub(date: week, appVersion: "3.2.0", in: context),
            .stub(date: week, appVersion: "3.2.0", in: context),
        ]

        let matrix = try SessionObject.matrix(of: batch)

        #expect(matrix.version == "3.2.0")
        #expect(matrix.category == nil)
    }

    @Test("matrix(of:) leaves the version nil for version-less sessions")
    func testMatrixWithoutVersionHasNilVersion() throws {
        let batch: [SessionObject] = [
            .stub(date: week, appVersion: nil, in: context)
        ]

        let matrix = try SessionObject.matrix(of: batch)

        #expect(matrix.version == nil)
    }

    @Test("launch(in:) returns launch matching launchID")
    func testLaunch() throws {
        let session = SessionObject.stub(date: week, in: context)
        let launchID = session.launchID

        let launch = LaunchObject.stub(date: week, in: context)
        launch.launchID = launchID

        LaunchObject.stub(date: week, in: context).launchID = UUID()

        try context.save()

        let result = try session.launch(in: context)
        #expect(result?.launchID == launchID)
    }
}
