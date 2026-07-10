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
    let week = TestDate.reference.startOfWeek

    @Test("sessions relationship holds the sessions linked to the launch")
    func testSessions() throws {
        let launch = LaunchObject.stub(date: week, in: context)

        SessionObject.stub(date: week, launch: launch, in: context)
        SessionObject.stub(date: week.addingHour(), launch: launch, in: context)
        SessionObject.stub(date: week, in: context)

        try context.save()

        #expect(launch.sessions.count == 2)
        #expect(launch.sessions.allSatisfy { $0.launch == launch })
    }

    @Test("versions relationship holds the versions linked to the launch")
    func testVersions() throws {
        let launch = LaunchObject.stub(date: week, in: context)

        VersionObject.stub(date: week, appVersion: "2.0", launch: launch, in: context)
        VersionObject.stub(date: week, appVersion: "1.0", in: context)

        try context.save()

        #expect(launch.versions.count == 1)
        #expect(launch.versions.first?.appVersion == "2.0")
    }
}
