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
@Suite("InstallEntry+Monitor")
struct InstallEntryMonitorTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let identity = Identity.stub

    @Test("trigger creates an InstallEntry on empty store")
    func createsFirst() throws {
        try InstallEntry.Trigger(installID: identity.install, deviceID: identity.device).execute(in: context)

        let installs = try context.fetchAll(InstallEntry.self)
        #expect(installs.count == 1)
        #expect(installs.first?.installID == identity.install)
    }

    @Test("trigger is a no-op when an InstallEntry for the current install already exists")
    func skipsWhenExists() throws {
        try InstallEntry.Trigger(installID: identity.install, deviceID: identity.device).execute(in: context)
        try InstallEntry.Trigger(installID: identity.install, deviceID: identity.device).execute(in: context)
        try InstallEntry.Trigger(installID: identity.install, deviceID: identity.device).execute(in: context)

        let installs = try context.fetchAll(InstallEntry.self)
        #expect(installs.count == 1)
    }

    @Test("trigger creates a new InstallEntry when existing records belong to a different install")
    func createsWhenInstallChanged() throws {
        let prior = InstallEntry.stub(date: Date(), in: context)
        prior.installID = UUID()
        try context.save()

        try InstallEntry.Trigger(installID: identity.install, deviceID: identity.device).execute(in: context)

        let installs = try context.fetchAll(InstallEntry.self)
        #expect(installs.count == 2)
        #expect(installs.contains { $0.installID == identity.install })
    }
}
