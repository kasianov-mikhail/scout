//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import ScoutCore
@testable import ScoutTestSupport

@MainActor
@Suite("InstallEntry")
struct InstallEntryTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let week = TestDate.reference.startOfWeek

    @Test("versions are reachable through the install's launches")
    func testVersions() throws {
        let install = InstallEntry.stub(date: week, in: context)
        let launch = LaunchEntry.stub(date: week, install: install, in: context)

        VersionEntry.stub(date: week, appVersion: "1.0", launch: launch, in: context)
        VersionEntry.stub(date: week.addingHour(), appVersion: "2.0", launch: launch, in: context)

        let otherLaunch = LaunchEntry.stub(date: week, in: context)
        VersionEntry.stub(date: week, appVersion: "3.0", launch: otherLaunch, in: context)

        try context.save()

        let versions = install.launches.flatMap(\.versions)
        #expect(versions.count == 2)
        #expect(Set(versions.compactMap(\.appVersion)) == ["1.0", "2.0"])
    }
}
