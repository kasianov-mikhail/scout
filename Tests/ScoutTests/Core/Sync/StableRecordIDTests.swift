//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Testing

@testable import Scout

@MainActor
@Suite("Stable record IDs")
struct StableRecordIDTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(timeIntervalSince1970: 1_724_457_600)

    @Test("DeviceObject.record is stable across calls")
    func deviceStable() {
        let device = DeviceObject.stub(date: date, in: context)
        #expect(device.record.id == device.record.id)
        #expect(device.record.id.recordName == device.deviceID.uuidString)
    }

    @Test("InstallObject.record is stable across calls")
    func installStable() {
        let install = InstallObject.stub(date: date, in: context)
        #expect(install.record.id == install.record.id)
        #expect(install.record.id.recordName == install.installID.uuidString)
    }

    @Test("LaunchObject.record is stable across calls")
    func launchStable() {
        let launch = LaunchObject.stub(date: date, in: context)
        launch.launchID = UUID()
        #expect(launch.record.id == launch.record.id)
        #expect(launch.record.id.recordName == launch.launchID.uuidString)
    }

    @Test("SessionObject.record is stable across calls")
    func sessionStable() {
        let session = SessionObject.stub(date: date, in: context)
        session.sessionID = UUID()
        #expect(session.record.id == session.record.id)
        #expect(session.record.id.recordName == session.sessionID.uuidString)
    }

    @Test("EventObject.record is stable across calls")
    func eventStable() {
        let event = EventObject.stub(name: "test", date: date, in: context)
        let expected = event.eventID.uuidString
        #expect(event.record.id == event.record.id)
        #expect(event.record.id.recordName == expected)
    }

    @Test("VersionObject.record is stable across calls")
    func versionStable() {
        let version = VersionObject.stub(date: date, appVersion: "1.2.3", in: context)
        version.buildNumber = "42"
        let expected = "\(version.installID.uuidString)-1.2.3-42"
        #expect(version.record.id == version.record.id)
        #expect(version.record.id.recordName == expected)
    }

    @Test("Different objects of the same type produce different recordIDs")
    func uniqueness() {
        let launch1 = LaunchObject.stub(date: date, in: context)
        launch1.launchID = UUID()
        let launch2 = LaunchObject.stub(date: date, in: context)
        launch2.launchID = UUID()

        #expect(launch1.record.id != launch2.record.id)
    }
}
