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
@Suite("InstallObject")
struct InstallObjectTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let week = TestDate.reference.startOfWeek

    @Test("versions(in:) returns versions whose install relationship matches")
    func testVersions() throws {
        let install = InstallObject.stub(date: week, in: context)

        let v1 = VersionObject.stub(date: week, appVersion: "1.0", in: context)
        v1.install = install

        let v2 = VersionObject.stub(date: week.addingHour(), appVersion: "2.0", in: context)
        v2.install = install

        VersionObject.stub(date: week, appVersion: "3.0", in: context).install = InstallObject.stub(date: week, in: context)

        try context.save()

        let versions = try install.versions(in: context)
        #expect(versions.count == 2)
        #expect(versions[0].appVersion == "1.0")
        #expect(versions[1].appVersion == "2.0")
    }
}
