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
@Suite("VersionMarker+Monitor")
struct VersionMarkerMonitorTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("mark records one marker per install, name and version")
    func markIsIdempotent() throws {
        let install = UUID()

        try VersionMarker.mark(name: VersionMarker.installName, installID: install, appVersion: "2.0", in: context)
        try VersionMarker.mark(name: VersionMarker.installName, installID: install, appVersion: "2.0", in: context)

        let markers = try context.fetchAll(VersionMarker.self)
        #expect(markers.count == 1)
        #expect(markers.first?.installID == install)
        #expect(markers.first?.appVersion == "2.0")
    }

    @Test("Different versions, names or installs get their own markers")
    func markDistinguishes() throws {
        let install = UUID()

        try VersionMarker.mark(name: VersionMarker.installName, installID: install, appVersion: "2.0", in: context)
        try VersionMarker.mark(name: VersionMarker.installName, installID: install, appVersion: "3.0", in: context)
        try VersionMarker.mark(name: VersionMarker.crashName, installID: install, appVersion: "2.0", in: context)
        try VersionMarker.mark(name: VersionMarker.installName, installID: UUID(), appVersion: "2.0", in: context)

        #expect(try context.fetchAll(VersionMarker.self).count == 4)
    }

    @Test("mark ignores a missing version")
    func markSkipsNilVersion() throws {
        try VersionMarker.mark(name: VersionMarker.installName, installID: UUID(), appVersion: nil, in: context)
        #expect(try context.fetchAll(VersionMarker.self).isEmpty)
    }
}
