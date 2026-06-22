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
@Suite("CrashObject")
struct CrashObjectTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(year: 2025, month: 1, day: 6)

    @Test("matrix(of:) aggregates every crash into a single \"Crash\" matrix")
    func testMatrixAggregatesByRecordType() throws {
        let batch: [CrashObject] = [
            makeCrashObject(name: "SIGABRT", date: date),
            makeCrashObject(name: "SIGSEGV", date: date),
            makeCrashObject(name: "SIGSEGV", date: date.addingHour()),
        ]

        let matrix = try CrashObject.matrix(of: batch)

        #expect(matrix.recordType == Int.recordType)
        #expect(matrix.name == CrashObject.recordType.rawValue)
        #expect(matrix.date == date.startOfWeek)
        #expect(matrix.cells.map(\.value).reduce(0, +) == 3)
    }

    private func makeCrashObject(name: String, date: Date) -> CrashObject {
        let entity = NSEntityDescription.entity(forEntityName: "CrashObject", in: context)!
        let object = CrashObject(entity: entity, insertInto: context)
        object.name = name
        object.date = date
        object.crashID = UUID()
        object.syncState = .pending
        return object
    }
}
