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
@Suite("VersionMarker")
struct VersionMarkerTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(year: 2025, month: 1, day: 6)

    @Test("matrix(of:) carries the marker name and version, counting markers")
    func testMatrix() throws {
        let batch = [
            stub(name: VersionMarker.installName, version: "2.0"),
            stub(name: VersionMarker.installName, version: "2.0"),
        ]

        let matrix = try VersionMarker.matrix(of: batch)

        #expect(matrix.name == VersionMarker.installName)
        #expect(matrix.version == "2.0")
        #expect(matrix.cells.map(\.value).reduce(0, +) == 2)
    }

    private func stub(name: String, version: String) -> VersionMarker {
        let marker = context.insert(VersionMarker.self)
        marker.markerID = UUID()
        marker.name = name
        marker.appVersion = version
        marker.date = date
        return marker
    }
}
