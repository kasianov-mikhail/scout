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

    @Test("sessions(in:) returns sessions whose launch relationship matches")
    func testSessions() throws {
        let launch = LaunchObject.stub(date: week, in: context)

        let session1 = SessionObject.stub(date: week, in: context)
        session1.launch = launch

        let session2 = SessionObject.stub(date: week.addingHour(), in: context)
        session2.launch = launch

        SessionObject.stub(date: week, in: context).launch = LaunchObject.stub(date: week, in: context)

        try context.save()

        let sessions = try launch.sessions(in: context)
        #expect(sessions.count == 2)
        #expect(sessions[0].launch === launch)
        #expect(sessions[1].launch === launch)
    }

    @Test("version(in:) returns version whose launch relationship matches")
    func testVersion() throws {
        let launch = LaunchObject.stub(date: week, in: context)

        let version = VersionObject.stub(date: week, appVersion: "2.0", in: context)
        version.launch = launch

        VersionObject.stub(date: week, appVersion: "1.0", in: context).launch = LaunchObject.stub(date: week, in: context)

        try context.save()

        let result = try launch.version(in: context)
        #expect(result?.appVersion == "2.0")
        #expect(result?.launch === launch)
    }
}
