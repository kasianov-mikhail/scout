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
@Suite("ExitEntry")
struct ExitEntryTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(year: 2025, month: 1, day: 6)

    @Test("The record carries the reason, count, version, and window")
    func recordCarriesExitFields() {
        let exitID = UUID()
        let object = makeExit(exitID: exitID)
        object.windowStart = date.addingDay(-1)

        let record = object.record

        #expect(record.recordType == "Exit")
        #expect(record.recordID == exitID.uuidString)
        #expect(record["category"] == "watchdog")
        #expect(record["value"] == 3)
        #expect(record["app_version"] == "3.2.0")
        #expect(record["date"] == date)
        #expect(record["date_start"] == date.addingDay(-1))
        #expect(record["day"] == date.startOfDay)
    }

    @Test("The record leaves out a missing window start")
    func recordOmitsMissingWindowStart() {
        #expect(makeExit(exitID: UUID()).record.fields["date_start"] == nil)
    }

    private func makeExit(exitID: UUID) -> ExitEntry {
        let object = context.insert(ExitEntry.self)
        object.exitID = exitID
        object.reason = "watchdog"
        object.count = 3
        object.appVersion = "3.2.0"
        object.date = date
        return object
    }
}
