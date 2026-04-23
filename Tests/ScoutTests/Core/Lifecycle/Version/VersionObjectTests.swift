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
@Suite("VersionObject")
struct VersionObjectTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let week = Date(timeIntervalSince1970: 1_724_457_600).startOfWeek

    @Test("parse(of:) produces correct GridCell<Int> counts by date")
    func testParseOf() throws {
        let batch: [VersionObject] = [
            .stub(date: week, synced: false, in: context),
            .stub(date: week, synced: false, in: context),
            .stub(date: week.addingHour(), synced: false, in: context),
        ]

        let cells = VersionObject.parse(of: batch)

        #expect(
            cells.sorted() == [
                GridCell(row: 1, column: 0, value: 2),
                GridCell(row: 1, column: 1, value: 1),
            ])
    }

    @Test("launches(in:) returns all launches with same appVersion")
    func testLaunches() throws {
        let launchID1 = UUID()
        let launchID2 = UUID()
        let launchID3 = UUID()

        let v1 = VersionObject.stub(date: week, appVersion: "2.0", in: context)
        v1.launchID = launchID1

        let v2 = VersionObject.stub(date: week.addingHour(), appVersion: "2.0", in: context)
        v2.launchID = launchID2

        // Different version
        let v3 = VersionObject.stub(date: week, appVersion: "1.0", in: context)
        v3.launchID = launchID3

        let l1 = LaunchObject.stub(date: week, in: context)
        l1.launchID = launchID1

        let l2 = LaunchObject.stub(date: week.addingHour(), in: context)
        l2.launchID = launchID2

        let l3 = LaunchObject.stub(date: week, in: context)
        l3.launchID = launchID3

        try context.save()

        let launches = try v1.launches(in: context)
        #expect(launches.count == 2)
        #expect(launches.allSatisfy { $0.launchID == launchID1 || $0.launchID == launchID2 })
    }

    @Test("install(in:) returns install matching installID")
    func testInstall() throws {
        let version = VersionObject.stub(date: week, appVersion: "2.0", in: context)
        let installID = version.installID

        let install = InstallObject.stub(date: week, in: context)
        install.installID = installID

        // Install with different installID
        InstallObject.stub(date: week, in: context).installID = UUID()

        try context.save()

        let result = try version.install(in: context)
        #expect(result?.installID == installID)
    }
}
