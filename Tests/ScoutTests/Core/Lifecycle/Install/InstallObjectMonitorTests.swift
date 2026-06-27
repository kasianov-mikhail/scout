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
@Suite("InstallObject+Monitor")
struct InstallObjectMonitorTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("trigger creates an InstallObject on empty store")
    func createsFirst() throws {
        try InstallObject.trigger(in: context)

        let installs = try context.fetchAll(InstallObject.self)
        #expect(installs.count == 1)
        #expect(installs.first?.installID == IDs.install)
    }

    @Test("trigger is a no-op when an InstallObject for the current install already exists")
    func skipsWhenExists() throws {
        try InstallObject.trigger(in: context)
        try InstallObject.trigger(in: context)
        try InstallObject.trigger(in: context)

        let installs = try context.fetchAll(InstallObject.self)
        #expect(installs.count == 1)
    }

    @Test("trigger creates a new InstallObject when existing records belong to a different install")
    func createsWhenInstallChanged() throws {
        let prior = InstallObject.stub(date: Date(), in: context)
        prior.installID = UUID()
        try context.save()

        try InstallObject.trigger(in: context)

        let installs = try context.fetchAll(InstallObject.self)
        #expect(installs.count == 2)
        #expect(installs.contains { $0.installID == IDs.install })
    }
}
