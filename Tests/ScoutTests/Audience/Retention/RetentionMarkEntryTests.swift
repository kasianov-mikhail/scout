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
@Suite("RetentionMarkEntry")
struct RetentionMarkEntryTests {
    let context = NSManagedObjectContext.inMemoryContext()

    private func makeInstall() throws -> InstallEntry {
        let install = InstallEntry.stub(date: TestDate.reference.addingTimeInterval(5 * .hour), in: context)
        install.installID = UUID()
        install.startCohort()
        try install.markInstall()
        return install
    }

    private func names() throws -> Set<String> {
        Set(try context.fetchAll(RetentionMarkEntry.self).map(\.name))
    }

    @Test("A new install is stamped with the OS and counted in its cohort")
    func newInstall() throws {
        try InstallEntry.Trigger(installID: UUID(), deviceID: UUID()).execute(in: context)

        let install = try #require(try context.fetchAll(InstallEntry.self).first)
        #expect(install.osVersion == SystemInfo.osVersion)
        #expect(try names() == ["install"])
    }

    @Test("An install first written by a linked session starts its cohort once")
    func linkedSessionInstall() throws {
        let identity = Identity.stub
        _ = try context.linkedSession(identity.snapshot, date: Date())
        try context.save()

        let trigger = InstallEntry.Trigger(installID: identity.install, deviceID: identity.device)
        try trigger.execute(in: context)
        try trigger.execute(in: context)

        let install = try #require(try context.fetchAll(InstallEntry.self).first)
        #expect(install.osVersion == SystemInfo.osVersion)
        #expect(try context.fetchAll(RetentionMarkEntry.self).count == 1)
        #expect(try names() == ["install"])
    }

    @Test("An install first written by an incident flush starts its cohort")
    func incidentFlushInstall() throws {
        let identity = Identity.stub
        let crash = CrashInfo(name: "SIGABRT", reason: nil, stackTrace: [], backtrace: Backtrace(images: [], threads: []), identity: identity)

        try crash.log(deviceID: identity.device, context: context)

        let install = try #require(try context.fetchAll(InstallEntry.self).first)
        #expect(install.osVersion == SystemInfo.osVersion)
        #expect(try names() == ["crash"])

        try InstallEntry.Trigger(installID: identity.install, deviceID: identity.device).execute(in: context)

        #expect(try names() == ["install", "crash"])
    }

    @Test("A known install starts no cohort when the trigger runs again")
    func knownInstall() throws {
        let install = InstallEntry.stub(date: TestDate.reference, in: context)
        install.installID = UUID()
        try context.save()

        try InstallEntry.Trigger(installID: install.installID, deviceID: UUID()).execute(in: context)

        #expect(install.osVersion == nil)
        #expect(try names().isEmpty)
    }

    @Test("The record carries the milestone, the install day and the install's OS")
    func record() throws {
        let install = try makeInstall()
        install.osVersion = "iOS 18.2"

        let mark = try #require(try context.fetchAll(RetentionMarkEntry.self).first)
        let record = mark.record

        #expect(record.recordType == RetentionMarkEntry.recordType)
        #expect(record.recordID == "\(install.installID.uuidString)-install")
        #expect(record["name"] == "install")
        #expect(record["install_date"] == install.date)
        #expect(record["os_version"] == "iOS 18.2")
        #expect(record["install_id"] == install.installID.uuidString)
    }

    @Test("Visits mark the retention days once and skip the days between them")
    func visits() throws {
        let install = try makeInstall()

        for day in [0, 0, 1, 2, 3, 3, 8, 30, 31] {
            try install.markVisit(date: TestDate.reference.addingDay(day).addingTimeInterval(20 * .hour))
        }

        #expect(try context.fetchAll(RetentionMarkEntry.self).count == 5)
        #expect(try names() == ["install", "day0", "day1", "day3", "day30"])
    }

    @Test("An install from before the marks gets none")
    func legacyInstall() throws {
        let install = InstallEntry.stub(date: TestDate.reference, in: context)
        install.installID = UUID()

        try install.markVisit(date: TestDate.reference.addingDay(7))
        try install.markIncident(milestone: .crash, date: TestDate.reference.addingDay(2))

        #expect(try names().isEmpty)
    }

    @Test("Crashes and hangs count once within the first 31 days")
    func incidents() throws {
        let install = try makeInstall()

        try install.markIncident(milestone: .crash, date: TestDate.reference.addingDay(2))
        try install.markIncident(milestone: .crash, date: TestDate.reference.addingDay(4))
        try install.markIncident(milestone: .hang, date: TestDate.reference.addingDay(31))
        try install.markIncident(milestone: .hang, date: TestDate.reference.addingTimeInterval(-.hour))

        #expect(try context.fetchAll(RetentionMarkEntry.self).count == 2)
        #expect(try names() == ["install", "crash"])
    }

    @Test("Entering the foreground on the install day marks day 0")
    func foreground() throws {
        let identity = Identity.stub

        for command in identity.startupCommands(bundle: .stub(appVersion: "1.0", buildNumber: "1")) + identity.foregroundCommands {
            try command.execute(in: context)
        }

        #expect(try names() == ["install", "day0"])
    }

    @Test("Milestone names round-trip")
    func milestoneNames() {
        let milestones: [RetentionMilestone] = [.install, .crash, .hang] + RetentionCohort.dayOffsets.map(RetentionMilestone.day)

        #expect(milestones.map { RetentionMilestone(name: $0.name) } == milestones)
        #expect(RetentionMilestone(name: "dayx") == nil)
        #expect(RetentionMilestone(name: "") == nil)
    }
}
