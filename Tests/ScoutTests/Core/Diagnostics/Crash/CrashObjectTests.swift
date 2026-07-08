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
@Suite("CrashObject")
struct CrashObjectTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let date = Date(year: 2025, month: 1, day: 6)

    @Test("record includes the crash fingerprint")
    func testRecordIncludesStoredFingerprint() {
        let object = makeCrashObject(name: "SIGABRT", date: date)
        object.fingerprint = "stored-fingerprint"

        #expect(object.record["fingerprint"] == "stored-fingerprint")
    }

    @Test("record includes the session ID")
    func testRecordIncludesSessionID() {
        let object = makeCrashObject(name: "SIGABRT", date: date)
        let session = SessionObject.stub(date: date, in: context)
        object.session = session

        #expect(object.record["session_id"] == session.id.uuidString)
    }

    @Test("record computes a fallback fingerprint for migrated crashes")
    func testRecordComputesFallbackFingerprint() throws {
        let object = makeCrashObject(name: "SIGABRT", date: date)
        object.reason = "Fatal error"
        object.stackTrace = try JSONEncoder().encode(["frame0"])

        #expect(object.record["fingerprint"] == CrashFingerprint(name: "SIGABRT", reason: "Fatal error", stackTrace: ["frame0"]).value)
    }

    private func makeCrashObject(name: String, date: Date, appVersion: String? = nil) -> CrashObject {
        let entity = NSEntityDescription.entity(forEntityName: "CrashObject", in: context)!
        let object = CrashObject(entity: entity, insertInto: context)
        object.name = name
        object.date = date
        object.crashID = UUID()
        object.appVersion = appVersion
        return object
    }
}
