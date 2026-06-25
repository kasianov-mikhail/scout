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
@Suite("NamedObject")
struct NamedObjectTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(year: 2025, month: 1, day: 6)

    @Test("matrix(of:) groups by hour and counts")
    func testMatrixCounts() throws {
        let batch: [NamedObject] = [
            try .stub(name: "crash", date: date, in: context),
            try .stub(name: "crash", date: date, in: context),
            try .stub(name: "crash", date: date.addingHour(), in: context),
        ]

        let cells = try NamedObject.matrix(of: batch).cells

        #expect(cells.count == 2)
        #expect(cells.map(\.value).reduce(0, +) == 3)
    }

    @Test("matrix(of:) produces correct record type and name")
    func testMatrixOf() throws {
        let batch: [NamedObject] = [
            try .stub(name: "signal", date: date, in: context),
            try .stub(name: "signal", date: date.addingHour(), in: context),
        ]

        let matrix = try NamedObject.matrix(of: batch)

        #expect(type(of: matrix).recordType == Int.recordType)
        #expect(matrix.name == "signal")
        #expect(matrix.date == date.startOfWeek)
        #expect(matrix.cells.count == 2)
    }

    @Test("matrix(of:) throws when name is missing")
    func testMatrixThrowsOnMissingName() throws {
        let batch: [NamedObject] = [
            try .stub(name: nil, date: date, in: context)
        ]

        #expect(throws: [NamedObject].SeedError.self) {
            try NamedObject.matrix(of: batch)
        }
    }

    @Test("matrix(of:) throws when week is missing")
    func testMatrixThrowsOnMissingWeek() throws {
        let entity = try #require(NSEntityDescription.entity(forEntityName: "EventObject", in: context))
        let object = EventObject(entity: entity, insertInto: context)
        object.name = "test"

        #expect(throws: [NamedObject].SeedError.self) {
            try NamedObject.matrix(of: [object])
        }
    }
}

// MARK: - Stub

extension NamedObject {
    @discardableResult fileprivate static func stub(
        name: String?,
        date: Date,
        in context: NSManagedObjectContext
    ) throws -> NamedObject {
        let entity = try #require(NSEntityDescription.entity(forEntityName: "EventObject", in: context))
        let object = EventObject(entity: entity, insertInto: context)
        object.name = name
        object.date = date
        object.eventID = UUID()
        object.level = "info"
        return object
    }
}
