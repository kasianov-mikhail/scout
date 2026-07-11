//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation
import Testing

@testable import Scout

@MainActor
@Suite("logHang")
struct LogHangTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let deviceID = UUID()

    private func makeHangInfo(name: String, reason: String?, stackTrace: [String], duration: TimeInterval) -> HangInfo {
        HangInfo(name: name, reason: reason, stackTrace: stackTrace, duration: duration, identity: .stub)
    }

    @Test("Creates a HangEntry with correct fields")
    func createsHangObject() throws {
        let hang = makeHangInfo(name: "Main Thread Blocked", reason: "Main thread unresponsive for 4.2s", stackTrace: ["frame0"], duration: 4.2)

        try logHang(hang, deviceID: deviceID, context: context)

        let results = try context.fetchAll(HangEntry.self)

        #expect(results.count == 1)

        let object = try #require(results.first)
        let expectedFingerprint = CrashFingerprint(name: hang.name, reason: hang.reason, stackTrace: hang.stackTrace).value
        #expect(object.name == "Main Thread Blocked")
        #expect(object.fingerprint == expectedFingerprint)
        #expect(object.reason == "Main thread unresponsive for 4.2s")
        #expect(object.duration == 4.2)
        #expect(object.date == hang.date)
        #expect(object.installID == hang.installID)
        #expect(object.launchID == hang.launchID)
        #expect(object.sessionID == hang.sessionID)
        #expect(object.appVersion == hang.appVersion)
    }

    @Test("Preserves sessionID captured at hang time, not the recovery session")
    func preservesCapturedSessionID() throws {
        let hangSessionID = UUID()
        let identity = Identity(install: UUID(), launch: UUID(), device: UUID(), session: Protected(hangSessionID))
        let hang = HangInfo(name: "Main Thread Blocked", reason: nil, stackTrace: [], duration: 3.5, identity: identity)

        #expect(Identity.stub.session.current != hangSessionID)

        try logHang(hang, deviceID: deviceID, context: context)

        let object = try #require(try context.fetchAll(HangEntry.self).first)
        #expect(object.sessionID == hangSessionID)
    }

    @Test("Encodes stack trace as JSON data")
    func encodesStackTrace() throws {
        let hang = makeHangInfo(name: "Main Thread Blocked", reason: nil, stackTrace: ["main", "start"], duration: 3.5)

        try logHang(hang, deviceID: deviceID, context: context)

        let object = try #require(try context.fetchAll(HangEntry.self).first)

        let data = try #require(object.stackTrace)
        let decoded = try JSONDecoder().decode([String].self, from: data)
        #expect(decoded == ["main", "start"])
    }

    @Test("Handles nil reason")
    func handlesNilReason() throws {
        let hang = makeHangInfo(name: "Main Thread Blocked", reason: nil, stackTrace: [], duration: 3.5)

        try logHang(hang, deviceID: deviceID, context: context)

        let object = try #require(try context.fetchAll(HangEntry.self).first)
        #expect(object.reason == nil)
    }

    @Test("Saves to the context")
    func savesToContext() throws {
        let hang = makeHangInfo(name: "Main Thread Blocked", reason: nil, stackTrace: [], duration: 3.5)

        try logHang(hang, deviceID: deviceID, context: context)

        #expect(!context.hasChanges)
    }

    @Test("Skips hangs already logged under the same id")
    func skipsDuplicateID() throws {
        let hang = makeHangInfo(name: "Main Thread Blocked", reason: nil, stackTrace: [], duration: 3.5)
        let id = UUID()

        try logHang(hang, id: id, deviceID: deviceID, context: context)
        try logHang(hang, id: id, deviceID: deviceID, context: context)

        #expect(try context.fetchAll(HangEntry.self).count == 1)
    }
}
