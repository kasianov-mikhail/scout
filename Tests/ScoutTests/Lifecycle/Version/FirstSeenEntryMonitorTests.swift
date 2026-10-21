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
@Suite("FirstSeenEntry+Monitor")
struct FirstSeenEntryMonitorTests {
    let context = NSManagedObjectContext.inMemoryContext()

    private func makeInstall() -> InstallEntry {
        let install = InstallEntry.stub(date: Date(), in: context)
        install.installID = UUID()
        return install
    }

    @Test("mark records one marker per install, name and version")
    func markIsIdempotent() throws {
        let install = makeInstall()

        try install.mark(name: Version.installMarker, appVersion: "2.0")
        try install.mark(name: Version.installMarker, appVersion: "2.0")

        let markers = try context.fetchAll(FirstSeenEntry.self)
        #expect(markers.count == 1)
        #expect(markers.first?.install == install)
        #expect(markers.first?.appVersion == "2.0")
    }

    @Test("Different versions, names or installs get their own markers")
    func markDistinguishes() throws {
        let install = makeInstall()
        let other = makeInstall()

        try install.mark(name: Version.installMarker, appVersion: "2.0")
        try install.mark(name: Version.installMarker, appVersion: "3.0")
        try install.mark(name: Version.crashMarker, appVersion: "2.0")
        try other.mark(name: Version.installMarker, appVersion: "2.0")

        #expect(try context.fetchAll(FirstSeenEntry.self).count == 4)
    }

    @Test("mark ignores a missing version")
    func markSkipsNilVersion() throws {
        try makeInstall().mark(name: Version.installMarker, appVersion: nil)
        #expect(try context.fetchAll(FirstSeenEntry.self).isEmpty)
    }
}
