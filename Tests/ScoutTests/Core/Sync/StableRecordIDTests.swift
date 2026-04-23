//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData
import Testing

@testable import Scout

@MainActor
@Suite("Stable CKRecord IDs")
struct StableRecordIDTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(timeIntervalSince1970: 1_724_457_600)

    @Test("DeviceObject.toRecord is stable across calls")
    func deviceStable() {
        let device = DeviceObject.stub(date: date, in: context)
        #expect(device.toRecord.recordID == device.toRecord.recordID)
        #expect(device.toRecord.recordID.recordName == device.deviceID.uuidString)
    }

    @Test("InstallObject.toRecord is stable across calls")
    func installStable() {
        let install = InstallObject.stub(date: date, in: context)
        #expect(install.toRecord.recordID == install.toRecord.recordID)
        #expect(install.toRecord.recordID.recordName == install.installID.uuidString)
    }

    @Test("LaunchObject.toRecord is stable across calls")
    func launchStable() {
        let launch = LaunchObject.stub(date: date, in: context)
        launch.launchID = UUID()
        #expect(launch.toRecord.recordID == launch.toRecord.recordID)
        #expect(launch.toRecord.recordID.recordName == launch.launchID.uuidString)
    }

    @Test("SessionObject.toRecord is stable across calls")
    func sessionStable() {
        let session = SessionObject.stub(date: date, in: context)
        session.sessionID = UUID()
        #expect(session.toRecord.recordID == session.toRecord.recordID)
        #expect(session.toRecord.recordID.recordName == session.sessionID.uuidString)
    }

    @Test("EventObject.toRecord is stable across calls")
    func eventStable() {
        let event = EventObject.stub(name: "test", date: date, in: context)
        let expected = event.eventID!.uuidString
        #expect(event.toRecord.recordID == event.toRecord.recordID)
        #expect(event.toRecord.recordID.recordName == expected)
    }

    @Test("VersionObject.toRecord is stable across calls")
    func versionStable() {
        let version = VersionObject.stub(date: date, appVersion: "1.2.3", in: context)
        version.buildNumber = "42"
        let expected = "\(version.installID.uuidString)-1.2.3-42"
        #expect(version.toRecord.recordID == version.toRecord.recordID)
        #expect(version.toRecord.recordID.recordName == expected)
    }

    @Test("Different objects of the same type produce different recordIDs")
    func uniqueness() {
        let launch1 = LaunchObject.stub(date: date, in: context)
        launch1.launchID = UUID()
        let launch2 = LaunchObject.stub(date: date, in: context)
        launch2.launchID = UUID()

        #expect(launch1.toRecord.recordID != launch2.toRecord.recordID)
    }
}
