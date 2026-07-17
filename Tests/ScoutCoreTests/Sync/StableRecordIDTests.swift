//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import ScoutCore
@testable import ScoutTestSupport

@MainActor
@Suite("Stable record IDs")
struct StableRecordIDTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = TestDate.reference

    @Test("DeviceEntry.record is stable across calls")
    func deviceStable() {
        let device = DeviceEntry.stub(date: date, in: context)
        #expect(device.record.recordID == device.record.recordID)
        #expect(device.record.recordID == device.deviceID.uuidString)
    }

    @Test("InstallEntry.record is stable across calls")
    func installStable() {
        let install = InstallEntry.stub(date: date, in: context)
        #expect(install.record.recordID == install.record.recordID)
        #expect(install.record.recordID == install.installID.uuidString)
    }

    @Test("LaunchEntry.record is stable across calls")
    func launchStable() {
        let launch = LaunchEntry.stub(date: date, in: context)
        launch.launchID = UUID()
        #expect(launch.record.recordID == launch.record.recordID)
        #expect(launch.record.recordID == launch.launchID.uuidString)
    }

    @Test("SessionEntry.record is stable across calls")
    func sessionStable() {
        let session = SessionEntry.stub(date: date, in: context)
        session.sessionID = UUID()
        #expect(session.record.recordID == session.record.recordID)
        #expect(session.record.recordID == session.sessionID.uuidString)
    }

    @Test("EventEntry.record is stable across calls")
    func eventStable() {
        let event = EventEntry.stub(name: "test", date: date, in: context)
        let expected = event.eventID.uuidString
        #expect(event.record.recordID == event.record.recordID)
        #expect(event.record.recordID == expected)
    }

    @Test("VersionEntry.record is stable across calls")
    func versionStable() {
        let install = InstallEntry.stub(date: date, in: context)
        let launch = LaunchEntry.stub(date: date, install: install, in: context)
        let version = VersionEntry.stub(date: date, appVersion: "1.2.3", launch: launch, in: context)
        version.buildNumber = "42"
        let expected = "\(install.installID.uuidString)-1.2.3-42"
        #expect(version.record.recordID == version.record.recordID)
        #expect(version.record.recordID == expected)
    }

    @Test("Different objects of the same type produce different recordIDs")
    func uniqueness() {
        let launch1 = LaunchEntry.stub(date: date, in: context)
        launch1.launchID = UUID()
        let launch2 = LaunchEntry.stub(date: date, in: context)
        launch2.launchID = UUID()

        #expect(launch1.record.recordID != launch2.record.recordID)
    }
}
