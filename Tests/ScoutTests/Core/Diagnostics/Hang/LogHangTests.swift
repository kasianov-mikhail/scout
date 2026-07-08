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

    private func makeHangInfo(name: String, reason: String?, stackTrace: [String], duration: TimeInterval) -> HangInfo {
        HangInfo(name: name, reason: reason, stackTrace: stackTrace, duration: duration)
    }

    @Test("Creates a HangObject with correct fields")
    func createsHangObject() throws {
        let hang = makeHangInfo(name: "Main Thread Blocked", reason: "Main thread unresponsive for 4.2s", stackTrace: ["frame0"], duration: 4.2)

        let install = InstallObject.stub(date: Date(), in: context)
        install.installID = hang.installID
        let launch = LaunchObject.stub(date: Date(), in: context)
        launch.launchID = hang.launchID
        let session = SessionObject.stub(date: Date(), in: context)
        session.id = hang.sessionID

        try logHang(hang, context: context)

        let results = try context.fetchAll(HangObject.self)

        #expect(results.count == 1)

        let object = try #require(results.first)
        let expectedFingerprint = CrashFingerprint(name: hang.name, reason: hang.reason, stackTrace: hang.stackTrace).value
        #expect(object.name == "Main Thread Blocked")
        #expect(object.fingerprint == expectedFingerprint)
        #expect(object.reason == "Main thread unresponsive for 4.2s")
        #expect(object.duration == 4.2)
        #expect(object.date == hang.date)
        #expect(object.install === install)
        #expect(object.launch === launch)
        #expect(object.session === session)
        #expect(object.appVersion == hang.appVersion)
    }

    @Test("Preserves the session captured at hang time, not the recovery session")
    func preservesCapturedSessionID() throws {
        let hangSession = SessionObject.stub(date: Date(), in: context)
        let hang = HangInfo(name: "Main Thread Blocked", reason: nil, stackTrace: [], duration: 3.5, sessionID: hangSession.id)

        #expect(IDs.session != hangSession.id)

        try logHang(hang, context: context)

        let object = try #require(try context.fetchAll(HangObject.self).first)
        #expect(object.session === hangSession)
    }

    @Test("Encodes stack trace as JSON data")
    func encodesStackTrace() throws {
        let hang = makeHangInfo(name: "Main Thread Blocked", reason: nil, stackTrace: ["main", "start"], duration: 3.5)

        try logHang(hang, context: context)

        let object = try #require(try context.fetchAll(HangObject.self).first)

        let data = try #require(object.stackTrace)
        let decoded = try JSONDecoder().decode([String].self, from: data)
        #expect(decoded == ["main", "start"])
    }

    @Test("Handles nil reason")
    func handlesNilReason() throws {
        let hang = makeHangInfo(name: "Main Thread Blocked", reason: nil, stackTrace: [], duration: 3.5)

        try logHang(hang, context: context)

        let object = try #require(try context.fetchAll(HangObject.self).first)
        #expect(object.reason == nil)
    }

    @Test("Saves to the context")
    func savesToContext() throws {
        let hang = makeHangInfo(name: "Main Thread Blocked", reason: nil, stackTrace: [], duration: 3.5)

        try logHang(hang, context: context)

        #expect(!context.hasChanges)
    }

    @Test("Skips hangs already logged under the same id")
    func skipsDuplicateID() throws {
        let hang = makeHangInfo(name: "Main Thread Blocked", reason: nil, stackTrace: [], duration: 3.5)
        let id = UUID()

        try logHang(hang, id: id, context: context)
        try logHang(hang, id: id, context: context)

        #expect(try context.fetchAll(HangObject.self).count == 1)
    }
}
