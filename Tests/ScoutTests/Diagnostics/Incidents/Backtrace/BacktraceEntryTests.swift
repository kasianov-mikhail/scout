//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CoreData
import Testing

@testable import Scout
@testable import Support

@MainActor
@Suite("BacktraceEntry")
struct BacktraceEntryTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(year: 2025, month: 1, day: 6)

    @Test("The record carries the incident and the encoded backtrace")
    func recordFields() {
        let incidentID = UUID()
        let object = context.insert(BacktraceEntry.self)
        object.incidentID = incidentID
        object.appVersion = "3.2.0"
        object.payload = Data([1, 2, 3])
        object.date = date

        let record = object.record

        #expect(record.recordType == "Backtrace")
        #expect(record.recordID == UUID(incidentBacktrace: incidentID).uuidString)
        #expect(record["uuid"] == record.recordID)
        #expect(record["incident_id"] == incidentID.uuidString)
        #expect(record["backtrace"] == Data([1, 2, 3]))
        #expect(record["date"] == date)
        #expect(record["app_version"] == "3.2.0")
    }

    @Test("The record name is stable and never the incident's own")
    func recordName() {
        let incidentID = UUID()

        #expect(UUID(incidentBacktrace: incidentID) == UUID(incidentBacktrace: incidentID))
        #expect(UUID(incidentBacktrace: incidentID) != incidentID)
        #expect(UUID(incidentBacktrace: incidentID) != UUID(incidentBacktrace: UUID()))
    }
}
