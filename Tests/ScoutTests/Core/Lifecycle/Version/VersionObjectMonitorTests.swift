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
@Suite("VersionObject+Monitor")
struct VersionObjectMonitorTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let identity = Identity.stub

    // Seeds the current install/launch chain so triggered versions link to it
    // and dedup by `launch.install.installID` can find prior versions.
    private func seedCurrentLaunch() {
        let install = InstallObject.stub(date: Date(), in: context)
        LaunchObject.stub(date: Date(), install: install, in: context)
    }

    @Test("trigger creates a VersionObject on first call")
    func firstTrigger() throws {
        seedCurrentLaunch()
        try VersionObject.Trigger(
            installID: identity.install,
            launchID: identity.launch,
            bundle: .stub(appVersion: "1.0", buildNumber: "1")
        ).execute(in: context)

        let versions = try context.fetchAll(VersionObject.self)
        #expect(versions.count == 1)
        #expect(versions.first?.appVersion == "1.0")
        #expect(versions.first?.buildNumber == "1")
    }

    @Test("trigger is a no-op when version and build are unchanged")
    func noopOnUnchanged() throws {
        seedCurrentLaunch()
        try VersionObject.Trigger(
            installID: identity.install,
            launchID: identity.launch,
            bundle: .stub(appVersion: "1.0", buildNumber: "1")
        ).execute(in: context)
        try VersionObject.Trigger(
            installID: identity.install,
            launchID: identity.launch,
            bundle: .stub(appVersion: "1.0", buildNumber: "1")
        ).execute(in: context)
        try VersionObject.Trigger(
            installID: identity.install,
            launchID: identity.launch,
            bundle: .stub(appVersion: "1.0", buildNumber: "1")
        ).execute(in: context)

        let versions = try context.fetchAll(VersionObject.self)
        #expect(versions.count == 1)
    }

    @Test("trigger creates a new VersionObject when appVersion changes")
    func appVersionChange() throws {
        seedCurrentLaunch()
        try VersionObject.Trigger(
            installID: identity.install,
            launchID: identity.launch,
            bundle: .stub(appVersion: "1.0", buildNumber: "1")
        ).execute(in: context)
        try VersionObject.Trigger(
            installID: identity.install,
            launchID: identity.launch,
            bundle: .stub(appVersion: "2.0", buildNumber: "1")
        ).execute(in: context)

        let request = NSFetchRequest<VersionObject>(entityName: "VersionObject")
        request.sortDescriptors = [NSSortDescriptor(key: DateObject.datePrimitiveKey, ascending: true)]
        let versions = try context.fetch(request)

        #expect(versions.count == 2)
        #expect(versions.map(\.appVersion) == ["1.0", "2.0"])
    }

    @Test("trigger creates a new VersionObject when buildNumber changes")
    func buildNumberChange() throws {
        seedCurrentLaunch()
        try VersionObject.Trigger(
            installID: identity.install,
            launchID: identity.launch,
            bundle: .stub(appVersion: "1.0", buildNumber: "1")
        ).execute(in: context)
        try VersionObject.Trigger(
            installID: identity.install,
            launchID: identity.launch,
            bundle: .stub(appVersion: "1.0", buildNumber: "2")
        ).execute(in: context)

        let request = NSFetchRequest<VersionObject>(entityName: "VersionObject")
        request.sortDescriptors = [NSSortDescriptor(key: DateObject.datePrimitiveKey, ascending: true)]
        let versions = try context.fetch(request)

        #expect(versions.count == 2)
        #expect(versions.map(\.buildNumber) == ["1", "2"])
    }

    @Test("trigger ignores VersionObjects from other installs")
    func ignoresOtherInstalls() throws {
        let otherInstall = InstallObject.stub(date: Date(), in: context)
        otherInstall.installID = UUID()

        let otherLaunch = LaunchObject.stub(date: Date(), install: otherInstall, in: context)
        otherLaunch.launchID = UUID()

        VersionObject.stub(date: Date(), appVersion: "1.0", buildNumber: "1", launch: otherLaunch, in: context)
        try context.save()

        try VersionObject.Trigger(
            installID: identity.install,
            launchID: identity.launch,
            bundle: .stub(appVersion: "1.0", buildNumber: "1")
        ).execute(in: context)

        let versions = try context.fetchAll(VersionObject.self)
        #expect(versions.count == 2)
    }
}
