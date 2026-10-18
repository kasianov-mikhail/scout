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
@Suite("ConditionEntry")
struct ConditionEntryTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(year: 2025, month: 1, day: 6)

    @Test("The record carries the kind, value, and session")
    func recordCarriesConditionFields() {
        let conditionID = UUID()
        let session = SessionEntry.stub(date: date, appVersion: "3.2.0", in: context)
        let object = makeCondition(conditionID: conditionID)
        object.session = session

        let record = object.record

        #expect(record.recordType == "Condition")
        #expect(record.recordID == conditionID.uuidString)
        #expect(record["category"] == "memory_warning")
        #expect(record["value"] == 52_428_800.0)
        #expect(record["date"] == date)
        #expect(record["app_version"] == "3.2.0")
        #expect(record["session_id"] == session.sessionID.uuidString)
    }

    @Test("A session lists its conditions and outlives them")
    func sessionKeepsConditions() {
        let session = SessionEntry.stub(date: date, endDate: date.addingTimeInterval(60), in: context)
        let object = makeCondition(conditionID: UUID())
        object.session = session

        #expect(session.observations == [object])
        #expect(!session.isDeletable)
    }

    private func makeCondition(conditionID: UUID) -> ConditionEntry {
        let object = context.insert(ConditionEntry.self)
        object.conditionID = conditionID
        object.kind = "memory_warning"
        object.value = 52_428_800
        object.date = date
        return object
    }
}
