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

    @Test("session.launch returns the launch it was created during")
    func testLaunch() throws {
        let launch = LaunchObject.stub(date: week, in: context)
        let session = SessionObject.stub(date: week, in: context)
        session.launch = launch

        try context.save()

        #expect(session.launch === launch)
    }
}
