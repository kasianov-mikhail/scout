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
