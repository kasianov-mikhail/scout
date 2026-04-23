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
@Suite("LaunchObject+Monitor")
struct LaunchObjectMonitorTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("trigger creates a LaunchObject")
    func createsLaunch() throws {
        try LaunchObject.trigger(in: context)

        let launches = try context.fetch(NSFetchRequest<LaunchObject>(entityName: "LaunchObject"))
        #expect(launches.count == 1)
        #expect(launches.first?.launchID == IDs.launch)
        #expect(launches.first?.endDate == nil)
    }

    @Test("Launch stays open when a session inside it is completed")
    func launchRemainsOpenAfterSessionComplete() throws {
        try LaunchObject.trigger(in: context)
        try SessionObject.trigger(in: context)
        try SessionObject.complete(in: context)

        let launches = try context.fetch(NSFetchRequest<LaunchObject>(entityName: "LaunchObject"))
        #expect(launches.first?.endDate == nil)
    }
}
