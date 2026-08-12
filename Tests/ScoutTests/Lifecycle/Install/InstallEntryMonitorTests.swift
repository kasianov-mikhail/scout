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

    @Test("trigger links the device onto an install an earlier record created")
    func triggerLinksExistingInstall() throws {
        _ = try context.linkedSession(identity.snapshot, date: Date())
        try context.save()

        try InstallEntry.Trigger(installID: identity.install, deviceID: identity.device).execute(in: context)

        let installs = try context.fetchAll(InstallEntry.self)
        #expect(installs.count == 1)
        #expect(installs.first?.device?.deviceID == identity.device)
    }

    @Test("trigger queues a delivered install again after linking the device")
    func triggerRequeuesLinkedInstall() throws {
        DeviceEntry.stub(date: Date(), in: context)
        let install = InstallEntry.stub(date: Date(), in: context)
        let delivery = install.seedDelivery(pending: false, attempts: 3, for: "cloud", in: context)
        try context.save()

        try InstallEntry.Trigger(installID: identity.install, deviceID: identity.device).execute(in: context)

        #expect(delivery.isPending)
        #expect(delivery.attempts == 0)
    }

    @Test("trigger leaves the delivery alone when the install is already linked")
    func triggerKeepsDeliveryForLinkedInstall() throws {
        let device = DeviceEntry.stub(date: Date(), in: context)
        let install = InstallEntry.stub(date: Date(), device: device, in: context)
        let delivery = install.seedDelivery(pending: false, attempts: 3, for: "cloud", in: context)
        try context.save()

        try InstallEntry.Trigger(installID: identity.install, deviceID: identity.device).execute(in: context)

        #expect(delivery.isPending == false)
        #expect(delivery.attempts == 3)
    }
}
