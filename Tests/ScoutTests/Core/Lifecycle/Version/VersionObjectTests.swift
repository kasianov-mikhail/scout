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
    let week = TestDate.reference.startOfWeek

    @Test("launch relationship points at the owning launch")
    func testLaunch() throws {
        let launch = LaunchObject.stub(date: week, in: context)
        let version = VersionObject.stub(date: week, appVersion: "2.0", launch: launch, in: context)

        try context.save()

        #expect(version.launch == launch)
    }

    @Test("install is reachable through the launch")
    func testInstall() throws {
        let install = InstallObject.stub(date: week, in: context)
        let launch = LaunchObject.stub(date: week, install: install, in: context)
        let version = VersionObject.stub(date: week, appVersion: "2.0", launch: launch, in: context)

        try context.save()

        #expect(version.launch?.install == install)
    }
}
