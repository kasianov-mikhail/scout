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
@Suite("FirstSeenEntry")
struct FirstSeenEntryTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("The record carries the marker name, version and install")
    func record() throws {
        let install = InstallEntry.stub(date: TestDate.reference, in: context)
        install.installID = UUID()
        try install.mark(name: Version.crashMarker, appVersion: "2.0")

        let record = try #require(context.fetchAll(FirstSeenEntry.self).first).record

        #expect(record.recordType == FirstSeenEntry.recordType)
        #expect(record["name"] == Version.crashMarker)
        #expect(record["app_version"] == "2.0")
        #expect(record["install_id"] == install.installID.uuidString)
    }

    @Test("A marker marked again for the same install and version keeps its record name")
    func stableRecordName() throws {
        let install = InstallEntry.stub(date: TestDate.reference, in: context)
        install.installID = UUID()

        try install.mark(name: Version.installMarker, appVersion: "2.0")
        let first = try #require(context.fetchAll(FirstSeenEntry.self).first)
        let name = first.record.recordID
        context.delete(first)

        try install.mark(name: Version.installMarker, appVersion: "2.0")
        let second = try #require(context.fetchAll(FirstSeenEntry.self).first)

        #expect(second.record.recordID == name)
    }
}
