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
@Suite("logMetricKitExits")
struct LogMetricKitExitsTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let window = DateInterval(start: Date(timeIntervalSince1970: 1_750_000_000), duration: 86_400)
    let installID = UUID()

    @Test("Each reason becomes one row with its count, version, and window")
    func savesOneRowPerReason() throws {
        try logMetricKitExits(exits: makeExits(), installID: installID, context: context)

        let rows = try context.fetchAll(ExitEntry.self).sorted { $0.reason < $1.reason }
        #expect(rows.map(\.reason) == ["normal", "watchdog"])
        #expect(rows.map(\.count) == [9, 2])
        #expect(rows.allSatisfy { $0.appVersion == "3.2.0" })
        #expect(rows.allSatisfy { $0.windowStart == window.start && $0.date == window.end })
    }

    @Test("A redelivered report adds no rows")
    func redeliveryIsIgnored() throws {
        try logMetricKitExits(exits: makeExits(), installID: installID, context: context)
        try logMetricKitExits(exits: makeExits(), installID: installID, context: context)

        #expect(try context.fetchAll(ExitEntry.self).count == 2)
    }

    @Test("The next day's report adds its own rows")
    func nextDayIsKept() throws {
        let nextDay = DateInterval(start: window.end, duration: 86_400)

        try logMetricKitExits(exits: makeExits(), installID: installID, context: context)
        try logMetricKitExits(exits: makeExits(window: nextDay), installID: installID, context: context)

        #expect(try context.fetchAll(ExitEntry.self).count == 4)
    }

    private func makeExits(window: DateInterval? = nil) -> MetricKitExits {
        MetricKitExits(counts: [.normal: 9, .watchdog: 2], appVersion: "3.2.0", window: window ?? self.window)
    }
}
