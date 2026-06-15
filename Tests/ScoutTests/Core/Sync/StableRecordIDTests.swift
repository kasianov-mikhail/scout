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

    @Test("DeviceObject.toRecord is stable across calls")
    func deviceStable() {
        let device = DeviceObject.stub(date: date, in: context)
        #expect(device.toRecord.id == device.toRecord.id)
        #expect(device.toRecord.id.recordName == device.deviceID.uuidString)
    }

    @Test("InstallObject.toRecord is stable across calls")
    func installStable() {
        let install = InstallObject.stub(date: date, in: context)
        #expect(install.toRecord.id == install.toRecord.id)
        #expect(install.toRecord.id.recordName == install.installID.uuidString)
    }

    @Test("LaunchObject.toRecord is stable across calls")
    func launchStable() {
        let launch = LaunchObject.stub(date: date, in: context)
        launch.launchID = UUID()
        #expect(launch.toRecord.id == launch.toRecord.id)
        #expect(launch.toRecord.id.recordName == launch.launchID.uuidString)
    }

    @Test("SessionObject.toRecord is stable across calls")
    func sessionStable() {
        let session = SessionObject.stub(date: date, in: context)
        session.sessionID = UUID()
        #expect(session.toRecord.id == session.toRecord.id)
        #expect(session.toRecord.id.recordName == session.sessionID.uuidString)
    }

    @Test("EventObject.toRecord is stable across calls")
    func eventStable() {
        let event = EventObject.stub(name: "test", date: date, in: context)
        let expected = event.eventID.uuidString
        #expect(event.toRecord.id == event.toRecord.id)
        #expect(event.toRecord.id.recordName == expected)
    }

    @Test("VersionObject.toRecord is stable across calls")
    func versionStable() {
        let version = VersionObject.stub(date: date, appVersion: "1.2.3", in: context)
        version.buildNumber = "42"
        let expected = "\(version.installID.uuidString)-1.2.3-42"
        #expect(version.toRecord.id == version.toRecord.id)
        #expect(version.toRecord.id.recordName == expected)
    }

    @Test("Different objects of the same type produce different recordIDs")
    func uniqueness() {
        let launch1 = LaunchObject.stub(date: date, in: context)
        launch1.launchID = UUID()
        let launch2 = LaunchObject.stub(date: date, in: context)
        launch2.launchID = UUID()

        #expect(launch1.toRecord.id != launch2.toRecord.id)
    }
}
