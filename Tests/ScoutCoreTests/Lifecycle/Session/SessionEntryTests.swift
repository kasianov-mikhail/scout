//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import ScoutCore
@testable import ScoutTestSupport

@MainActor
@Suite("SessionEntry")
struct SessionEntryTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let week = TestDate.reference.startOfWeek

    @Test("launch relationship points at the owning launch")
    func testLaunch() throws {
        let launch = LaunchEntry.stub(date: week, in: context)
        let session = SessionEntry.stub(date: week, launch: launch, in: context)

        LaunchEntry.stub(date: week, in: context)

        try context.save()

        #expect(session.launch == launch)
    }
}
