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
@Suite("VersionObject")
struct VersionObjectTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let week = TestDate.reference.startOfWeek

    @Test("launches(in:) returns all launches with same appVersion")
    func testLaunches() throws {
        let l1 = LaunchObject.stub(date: week, in: context)
        let l2 = LaunchObject.stub(date: week.addingHour(), in: context)
        let l3 = LaunchObject.stub(date: week, in: context)

        let v1 = VersionObject.stub(date: week, appVersion: "2.0", in: context)
        v1.launch = l1

        let v2 = VersionObject.stub(date: week.addingHour(), appVersion: "2.0", in: context)
        v2.launch = l2

        let v3 = VersionObject.stub(date: week, appVersion: "1.0", in: context)
        v3.launch = l3

        try context.save()

        let launches = try v1.launches(in: context)
        #expect(launches.count == 2)
        #expect(launches.allSatisfy { $0 === l1 || $0 === l2 })
    }

    @Test("launches(in:) returns an empty array when appVersion is nil")
    func testLaunchesNilAppVersion() throws {
        let version = VersionObject.stub(date: week, appVersion: "2.0", in: context)
        version.appVersion = nil

        try context.save()

        let launches = try version.launches(in: context)
        #expect(launches.isEmpty)
    }

    @Test("install returns the install it belongs to")
    func testInstall() throws {
        let version = VersionObject.stub(date: week, appVersion: "2.0", in: context)
        let install = InstallObject.stub(date: week, in: context)
        version.install = install

        try context.save()

        #expect(version.install === install)
    }
}
