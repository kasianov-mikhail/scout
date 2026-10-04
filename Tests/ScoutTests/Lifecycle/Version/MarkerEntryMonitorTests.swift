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
@Suite("MarkerEntry+Monitor")
struct MarkerEntryMonitorTests {
    let context = NSManagedObjectContext.inMemoryContext()

    private func makeInstall() -> InstallEntry {
        let install = InstallEntry.stub(date: Date(), in: context)
        install.installID = UUID()
        return install
    }

    @Test("mark records one marker per install, name and version")
    func markIsIdempotent() throws {
        let install = makeInstall()

        try MarkerEntry.mark(name: MarkerEntry.installName, install: install, appVersion: "2.0", in: context)
        try MarkerEntry.mark(name: MarkerEntry.installName, install: install, appVersion: "2.0", in: context)

        let markers = try context.fetchAll(MarkerEntry.self)
        #expect(markers.count == 1)
        #expect(markers.first?.install == install)
        #expect(markers.first?.appVersion == "2.0")
    }

    @Test("Different versions, names or installs get their own markers")
    func markDistinguishes() throws {
        let install = makeInstall()
        let other = makeInstall()

        try MarkerEntry.mark(name: MarkerEntry.installName, install: install, appVersion: "2.0", in: context)
        try MarkerEntry.mark(name: MarkerEntry.installName, install: install, appVersion: "3.0", in: context)
        try MarkerEntry.mark(name: MarkerEntry.crashName, install: install, appVersion: "2.0", in: context)
        try MarkerEntry.mark(name: MarkerEntry.installName, install: other, appVersion: "2.0", in: context)

        #expect(try context.fetchAll(MarkerEntry.self).count == 4)
    }

    @Test("mark ignores a missing version")
    func markSkipsNilVersion() throws {
        try MarkerEntry.mark(name: MarkerEntry.installName, install: makeInstall(), appVersion: nil, in: context)
        #expect(try context.fetchAll(MarkerEntry.self).isEmpty)
    }
}
