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
@Suite("MetricKitReport")
struct MetricKitReportTests {
    private let window = DateInterval(start: Date(timeIntervalSince1970: 1_750_000_000), duration: 86_400)
    private let installID = UUID()
    private let watchdog = DailyMetricReading(name: "exit", category: "watchdog", value: 1)
    private let context = NSManagedObjectContext.inMemoryContext()

    @Test("The same report gives the same id for a reading")
    func idIsDeterministic() {
        let first = makeReport().id(of: watchdog, installID: installID)
        let second = makeReport().id(of: watchdog, installID: installID)

        #expect(first == second)
    }

    @Test("The id differs by name, category, install, version, and window")
    func idSeparatesReadings() {
        let report = makeReport()
        let base = report.id(of: watchdog, installID: installID)

        let later = DateInterval(start: window.end, duration: 86_400)
        let others = [
            report.id(of: DailyMetricReading(name: "launch_time", category: "watchdog", value: 1), installID: installID),
            report.id(of: DailyMetricReading(name: "exit", category: "normal", value: 1), installID: installID),
            report.id(of: watchdog, installID: UUID()),
            makeReport(appVersion: "3.2.1").id(of: watchdog, installID: installID),
            makeReport(window: later).id(of: watchdog, installID: installID),
        ]

        #expect(Set(others + [base]).count == 6)
    }

    @Test("The value does not change the id")
    func valueKeepsId() {
        let report = makeReport()
        let recount = DailyMetricReading(name: "exit", category: "watchdog", value: 7)

        #expect(report.id(of: watchdog, installID: installID) == report.id(of: recount, installID: installID))
    }

    @Test("Each reading becomes one row with its value, version, and window")
    func savesOneRowPerReading() throws {
        try makeReport().log(installID: installID, context: context)

        let rows = try context.fetchAll(DailyMetricEntry.self).sorted { $0.name < $1.name }
        #expect(rows.map(\.name) == ["exit", "launch_time"])
        #expect(rows.map(\.category) == ["normal", "400"])
        #expect(rows.map(\.value) == [9, 2])
        #expect(rows.allSatisfy { $0.appVersion == "3.2.0" })
        #expect(rows.allSatisfy { $0.windowStart == window.start && $0.date == window.end })
    }

    @Test("A redelivered report adds no rows")
    func redeliveryIsIgnored() throws {
        try makeReport().log(installID: installID, context: context)
        try makeReport().log(installID: installID, context: context)

        #expect(try context.fetchAll(DailyMetricEntry.self).count == 2)
    }

    @Test("The next day's report adds its own rows")
    func nextDayIsKept() throws {
        let nextDay = DateInterval(start: window.end, duration: 86_400)

        try makeReport().log(installID: installID, context: context)
        try makeReport(window: nextDay).log(installID: installID, context: context)

        #expect(try context.fetchAll(DailyMetricEntry.self).count == 4)
    }

    private func makeReport(appVersion: String = "3.2.0", window: DateInterval? = nil) -> MetricKitReport {
        MetricKitReport(
            readings: [
                DailyMetricReading(name: "exit", category: "normal", value: 9),
                DailyMetricReading(name: "launch_time", category: "400", value: 2),
            ],
            appVersion: appVersion,
            window: window ?? self.window
        )
    }
}
