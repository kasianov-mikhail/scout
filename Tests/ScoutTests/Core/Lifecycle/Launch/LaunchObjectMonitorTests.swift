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
    let identity = Identity.stub

    @Test("trigger creates a LaunchObject")
    func createsLaunch() throws {
        try LaunchObject.trigger(launchID: identity.launch, installID: identity.install, in: context)

        let launches = try context.fetchAll(LaunchObject.self)
        #expect(launches.count == 1)
        #expect(launches.first?.launchID == identity.launch)
        #expect(launches.first?.endDate == nil)
    }

    @Test("Launch stays open when a session inside it is completed")
    func launchRemainsOpenAfterSessionComplete() throws {
        try LaunchObject.trigger(launchID: identity.launch, installID: identity.install, in: context)
        try SessionObject.trigger(session: identity.session, launchID: identity.launch, in: context)
        try SessionObject.complete(launchID: identity.launch, in: context)

        let launches = try context.fetchAll(LaunchObject.self)
        #expect(launches.first?.endDate == nil)
    }
}
