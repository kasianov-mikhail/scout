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
@Suite("HangObject")
struct HangObjectTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(year: 2025, month: 1, day: 6)

    @Test("record includes the hang fingerprint")
    func testRecordIncludesStoredFingerprint() {
        let object = makeHangObject(name: "Main Thread Blocked", date: date)
        object.fingerprint = "stored-fingerprint"

        #expect(object.record["fingerprint"] == "stored-fingerprint")
    }

    @Test("record includes the session ID")
    func testRecordIncludesSessionID() {
        let object = makeHangObject(name: "Main Thread Blocked", date: date)
        let session = SessionObject.stub(date: date, in: context)
        object.session = session

        #expect(object.record["session_id"] == session.sessionID.uuidString)
    }

    @Test("record includes the duration")
    func testRecordIncludesDuration() {
        let object = makeHangObject(name: "Main Thread Blocked", date: date)
        object.duration = 6.4

        #expect(object.record["duration"] == 6.4)
    }

    @Test("record computes a fallback fingerprint for migrated hangs")
    func testRecordComputesFallbackFingerprint() throws {
        let object = makeHangObject(name: "Main Thread Blocked", date: date)
        object.reason = "Main thread unresponsive for 4.2s"
        object.stackTrace = try JSONEncoder().encode(["frame0"])

        #expect(
            object.record["fingerprint"]
                == CrashFingerprint(name: "Main Thread Blocked", reason: "Main thread unresponsive for 4.2s", stackTrace: ["frame0"]).value)
    }

    private func makeHangObject(name: String, date: Date, appVersion: String? = nil) -> HangObject {
        let entity = NSEntityDescription.entity(forEntityName: "HangObject", in: context)!
        let object = HangObject(entity: entity, insertInto: context)
        object.name = name
        object.date = date
        object.hangID = UUID()
        object.appVersion = appVersion
        return object
    }
}
