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

    @Test("trigger creates a VersionObject on first call")
    func firstTrigger() throws {
        try VersionObject.trigger(appVersion: "1.0", buildNumber: "1", in: context)

        let versions = try context.fetchAll(VersionObject.self)
        #expect(versions.count == 1)
        #expect(versions.first?.appVersion == "1.0")
        #expect(versions.first?.buildNumber == "1")
    }

    @Test("trigger is a no-op when version and build are unchanged")
    func noopOnUnchanged() throws {
        try VersionObject.trigger(appVersion: "1.0", buildNumber: "1", in: context)
        try VersionObject.trigger(appVersion: "1.0", buildNumber: "1", in: context)
        try VersionObject.trigger(appVersion: "1.0", buildNumber: "1", in: context)

        let versions = try context.fetchAll(VersionObject.self)
        #expect(versions.count == 1)
    }

    @Test("trigger creates a new VersionObject when appVersion changes")
    func appVersionChange() throws {
        try VersionObject.trigger(appVersion: "1.0", buildNumber: "1", in: context)
        try VersionObject.trigger(appVersion: "2.0", buildNumber: "1", in: context)

        let request = NSFetchRequest<VersionObject>(entityName: "VersionObject")
        request.sortDescriptors = [NSSortDescriptor(key: "datePrimitive", ascending: true)]
        let versions = try context.fetch(request)

        #expect(versions.count == 2)
        #expect(versions.map(\.appVersion) == ["1.0", "2.0"])
    }

    @Test("trigger creates a new VersionObject when buildNumber changes")
    func buildNumberChange() throws {
        try VersionObject.trigger(appVersion: "1.0", buildNumber: "1", in: context)
        try VersionObject.trigger(appVersion: "1.0", buildNumber: "2", in: context)

        let request = NSFetchRequest<VersionObject>(entityName: "VersionObject")
        request.sortDescriptors = [NSSortDescriptor(key: "datePrimitive", ascending: true)]
        let versions = try context.fetch(request)

        #expect(versions.count == 2)
        #expect(versions.map(\.buildNumber) == ["1", "2"])
    }

    @Test("trigger ignores VersionObjects from other installs")
    func ignoresOtherInstalls() throws {
        let other = VersionObject.stub(date: Date(), appVersion: "1.0", buildNumber: "1", in: context)
        other.installID = UUID()
        try context.save()

        try VersionObject.trigger(appVersion: "1.0", buildNumber: "1", in: context)

        let versions = try context.fetchAll(VersionObject.self)
        #expect(versions.count == 2)
    }
}
