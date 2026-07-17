//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout
@testable import Support

@MainActor
@Suite("LaunchEntry+Monitor")
struct LaunchEntryMonitorTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let identity = Identity.stub

    @Test("trigger creates a LaunchEntry")
    func createsLaunch() throws {
        try LaunchEntry.Trigger(launchID: identity.launch, installID: identity.install).execute(in: context)

        let launches = try context.fetchAll(LaunchEntry.self)
        #expect(launches.count == 1)
        #expect(launches.first?.launchID == identity.launch)
        #expect(launches.first?.endDate == nil)
    }

    @Test("Launch stays open when a session inside it is completed")
    func launchRemainsOpenAfterSessionComplete() throws {
        try LaunchEntry.Trigger(launchID: identity.launch, installID: identity.install).execute(in: context)
        try SessionEntry.Trigger(session: identity.session, launchID: identity.launch).execute(in: context)
        try SessionEntry.Complete(launchID: identity.launch).execute(in: context)

        let launches = try context.fetchAll(LaunchEntry.self)
        #expect(launches.first?.endDate == nil)
    }
}
