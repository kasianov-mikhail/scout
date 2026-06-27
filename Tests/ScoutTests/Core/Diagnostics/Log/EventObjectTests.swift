//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

@MainActor
@Suite("EventObject")
struct EventObjectTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = TestDate.reference.startOfWeek

    @Test("matrix(of:) produces correct GridCell<Int> counts by hour")
    func testMatrixOf() throws {
        let batch: [EventObject] = [
            .stub(name: "name", date: date, in: context),
            .stub(name: "name", date: date, in: context),
            .stub(name: "name", date: date.addingHour(), in: context),
        ]

        let counts = try EventObject.matrix(of: batch).cells.map(\.value)
        #expect(counts.contains(2))
        #expect(counts.contains(1))
        #expect(counts.reduce(0, +) == 3)
    }
}
