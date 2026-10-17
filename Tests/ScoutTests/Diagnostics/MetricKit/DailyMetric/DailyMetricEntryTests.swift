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
@Suite("DailyMetricEntry")
struct DailyMetricEntryTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(year: 2025, month: 1, day: 6)

    @Test("The record carries the name, category, value, version, and window")
    func recordCarriesMetricFields() {
        let metricID = UUID()
        let object = makeMetric(metricID: metricID)
        object.category = "watchdog"
        object.windowStart = date.addingDay(-1)

        let record = object.record

        #expect(record.recordType == "DailyMetric")
        #expect(record.recordID == metricID.uuidString)
        #expect(record["name"] == "exit")
        #expect(record["category"] == "watchdog")
        #expect(record["value"] == 3)
        #expect(record["app_version"] == "3.2.0")
        #expect(record["date"] == date)
        #expect(record["date_start"] == date.addingDay(-1))
        #expect(record["day"] == date.startOfDay)
    }

    @Test("The record leaves out a missing category and window start")
    func recordOmitsMissingFields() {
        let fields = makeMetric(metricID: UUID()).record.fields

        #expect(fields["category"] == nil)
        #expect(fields["date_start"] == nil)
    }

    private func makeMetric(metricID: UUID) -> DailyMetricEntry {
        let object = context.insert(DailyMetricEntry.self)
        object.metricID = metricID
        object.name = "exit"
        object.value = 3
        object.appVersion = "3.2.0"
        object.date = date
        return object
    }
}
