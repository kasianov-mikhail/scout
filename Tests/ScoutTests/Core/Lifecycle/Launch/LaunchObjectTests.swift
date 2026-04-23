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
@Suite("LaunchObject")
struct LaunchObjectTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let week = Date(timeIntervalSince1970: 1_724_457_600).startOfWeek

    @Test("parse(of:) produces correct GridCell<Int> counts by date")
    func testParseOf() throws {
        let batch: [LaunchObject] = [
            .stub(date: week, synced: false, in: context),
            .stub(date: week, synced: false, in: context),
            .stub(date: week.addingHour(), synced: false, in: context),
        ]

        let cells = LaunchObject.parse(of: batch)

        #expect(
            cells.sorted() == [
                GridCell(row: 1, column: 0, value: 2),
                GridCell(row: 1, column: 1, value: 1),
            ])
    }

    @Test("sessions(in:) returns sessions matching launchID")
    func testSessions() throws {
        let launch = LaunchObject.stub(date: week, in: context)
        let launchID = launch.launchID

        let session1 = SessionObject.stub(date: week, in: context)
        session1.launchID = launchID

        let session2 = SessionObject.stub(date: week.addingHour(), in: context)
        session2.launchID = launchID

        // Session with different launchID
        SessionObject.stub(date: week, in: context).launchID = UUID()

        try context.save()

        let sessions = try launch.sessions(in: context)
        #expect(sessions.count == 2)
        #expect(sessions[0].launchID == launchID)
        #expect(sessions[1].launchID == launchID)
    }

    @Test("version(in:) returns version matching launchID")
    func testVersion() throws {
        let launch = LaunchObject.stub(date: week, in: context)
        let launchID = launch.launchID

        let version = VersionObject.stub(date: week, appVersion: "2.0", in: context)
        version.launchID = launchID

        // Version with different launchID
        VersionObject.stub(date: week, appVersion: "1.0", in: context).launchID = UUID()

        try context.save()

        let result = try launch.version(in: context)
        #expect(result?.appVersion == "2.0")
        #expect(result?.launchID == launchID)
    }
}
