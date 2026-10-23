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
@Suite("VisitEntry+Monitor")
struct VisitEntryMonitorTests {
    let context = NSManagedObjectContext.inMemoryContext()

    private func makeLaunch(device: DeviceEntry? = nil) -> LaunchEntry {
        let install = device.map { InstallEntry.stub(date: Date(year: 2026, month: 1, day: 1), device: $0, in: context) }
        return LaunchEntry.stub(date: Date(year: 2026, month: 1, day: 1), install: install, in: context)
    }

    private func purgeDelivered(entries: [LaunchScopeEntry]) throws {
        for entry in entries {
            entry.seedDelivery(pending: false, for: "cloud", in: context)
        }
        try SyncableEntry.purge(to: ["cloud"], in: context)
        try context.save()
    }

    @Test("Trigger records one visit per day")
    func triggerIsIdempotent() throws {
        let launch = makeLaunch()

        try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: 1, hour: 9))
            .execute(in: context)
        try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: 1, hour: 17))
            .execute(in: context)

        let visits = try context.fetchAll(VisitEntry.self)
        #expect(visits.count == 1)
        #expect(visits.first?.launch == launch)
        #expect(visits.first?.day == Date(year: 2026, month: 1, day: 1))
    }

    @Test("A new day gets its own visit")
    func triggerNextDay() throws {
        let launch = makeLaunch()

        try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: 1))
            .execute(in: context)
        try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: 2))
            .execute(in: context)

        #expect(try context.fetchAll(VisitEntry.self).count == 2)
    }

    @Test("Each new visit day stamps the days since the device's previous visit")
    func triggerStampsGaps() throws {
        let device = DeviceEntry.stub(date: Date(year: 2026, month: 1, day: 1), in: context)
        let launch = makeLaunch(device: device)

        for day in [1, 1, 4, 5] {
            try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: day, hour: 9), appVersion: "2.0")
                .execute(in: context)
        }
        try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 3, day: 1), appVersion: "2.1")
            .execute(in: context)

        let gaps = try context.fetchAll(VisitGapEntry.self).sorted { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }

        #expect(gaps.map(\.gap) == [30, 3, 1, 30])
        #expect(gaps.map(\.appVersion) == ["2.0", "2.0", "2.0", "2.1"])
        #expect(gaps.allSatisfy { $0.launch == launch })
        #expect(device.lastVisitDay == Date(year: 2026, month: 3, day: 1))
    }

    @Test("A purged visit keeps the day's gap from being stamped again")
    func triggerAfterPurgedVisit() throws {
        let device = DeviceEntry.stub(date: Date(year: 2026, month: 1, day: 1), in: context)
        let launch = makeLaunch(device: device)

        try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: 1, hour: 9))
            .execute(in: context)
        try purgeDelivered(entries: context.fetchAll(VisitEntry.self))
        try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: 1, hour: 17))
            .execute(in: context)

        #expect(try context.fetchAll(VisitEntry.self).isEmpty)
        #expect(try context.fetchAll(VisitGapEntry.self).map(\.gap) == [30])
        #expect(device.lastVisitDay == Date(year: 2026, month: 1, day: 1))
    }

    @Test("The next visit day counts its gap from a purged visit")
    func triggerNextDayAfterPurge() throws {
        let device = DeviceEntry.stub(date: Date(year: 2026, month: 1, day: 1), in: context)
        let launch = makeLaunch(device: device)

        try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: 1, hour: 9))
            .execute(in: context)
        try purgeDelivered(entries: context.fetchAll(LaunchScopeEntry.self))
        try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: 1, hour: 17))
            .execute(in: context)
        try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: 4))
            .execute(in: context)

        #expect(try context.fetchAll(VisitGapEntry.self).map(\.gap) == [3])
    }

    @Test("A clock set back skips the visit and keeps the last visit day")
    func triggerAfterClockRollback() throws {
        let device = DeviceEntry.stub(date: Date(year: 2026, month: 1, day: 1), in: context)
        let launch = makeLaunch(device: device)

        for day in [1, 4, 3] {
            try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: day, hour: 9))
                .execute(in: context)
        }
        #expect(device.lastVisitDay == Date(year: 2026, month: 1, day: 4))

        for day in [4, 5] {
            try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: day, hour: 17))
                .execute(in: context)
        }

        let gaps = try context.fetchAll(VisitGapEntry.self).sorted { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }

        #expect(gaps.map(\.day) == [1, 4, 5].map { Date(year: 2026, month: 1, day: $0) })
        #expect(gaps.map(\.gap) == [30, 3, 1])
        #expect(device.lastVisitDay == Date(year: 2026, month: 1, day: 5))
    }

    @Test("A visit without a known device stamps the longest gap")
    func triggerWithoutDevice() throws {
        let launch = makeLaunch()

        try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: 1)).execute(in: context)
        try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: 2)).execute(in: context)

        #expect(try context.fetchAll(VisitGapEntry.self).map(\.gap) == [30, 30])
    }

    @Test("A visit without a known device skips a day before a stored visit")
    func triggerWithoutDeviceAfterClockRollback() throws {
        let launch = makeLaunch()

        for day in [1, 4, 3] {
            try VisitEntry.Trigger(launchID: launch.launchID, date: Date(year: 2026, month: 1, day: day)).execute(in: context)
        }

        let days = try context.fetchAll(VisitEntry.self).compactMap(\.day).sorted()

        #expect(days == [1, 4].map { Date(year: 2026, month: 1, day: $0) })
        #expect(try context.fetchAll(VisitGapEntry.self).count == 2)
    }
}
