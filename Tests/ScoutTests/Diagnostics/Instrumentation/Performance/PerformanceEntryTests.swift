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
@Suite("PerformanceEntry")
struct PerformanceEntryTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(year: 2025, month: 1, day: 6)

    @Test("The record carries the metric, bucket, value, version, and window")
    func recordCarriesPerformanceFields() {
        let performanceID = UUID()
        let object = makePerformance(performanceID: performanceID)
        object.bucket = "400"
        object.windowStart = date.addingDay(-1)

        let record = object.record

        #expect(record.recordType == "Performance")
        #expect(record.recordID == performanceID.uuidString)
        #expect(record["name"] == "launch_time")
        #expect(record["category"] == "400")
        #expect(record["value"] == 7)
        #expect(record["app_version"] == "3.2.0")
        #expect(record["date"] == date)
        #expect(record["date_start"] == date.addingDay(-1))
        #expect(record["day"] == date.startOfDay)
    }

    @Test("The record leaves out a missing bucket and window start")
    func recordOmitsMissingFields() {
        let fields = makePerformance(performanceID: UUID()).record.fields

        #expect(fields["category"] == nil)
        #expect(fields["date_start"] == nil)
    }

    private func makePerformance(performanceID: UUID) -> PerformanceEntry {
        let object = context.insert(PerformanceEntry.self)
        object.performanceID = performanceID
        object.metric = "launch_time"
        object.value = 7
        object.appVersion = "3.2.0"
        object.date = date
        return object
    }
}
