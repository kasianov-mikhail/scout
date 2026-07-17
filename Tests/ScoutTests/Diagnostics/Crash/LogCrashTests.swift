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
@testable import ScoutTestSupport

@MainActor
@Suite("logCrash")
struct LogCrashTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let deviceID = UUID()

    private func makeCrashInfo(name: String, reason: String?, stackTrace: [String]) -> CrashInfo {
        CrashInfo(name: name, reason: reason, stackTrace: stackTrace, identity: .stub)
    }

    @Test("Creates a CrashEntry with correct fields")
    func createsCrashObject() throws {
        let crash = makeCrashInfo(name: "SIGABRT", reason: "Fatal error", stackTrace: ["frame0"])

        try logCrash(crash, deviceID: deviceID, context: context)

        let results = try context.fetchAll(CrashEntry.self)

        #expect(results.count == 1)

        let object = try #require(results.first)
        let expectedFingerprint = CrashFingerprint(name: crash.name, reason: crash.reason, stackTrace: crash.stackTrace)
            .value
        #expect(object.name == "SIGABRT")
        #expect(object.fingerprint == expectedFingerprint)
        #expect(object.reason == "Fatal error")
        #expect(object.date == crash.date)
        #expect(object.installID == crash.installID)
        #expect(object.launchID == crash.launchID)
        #expect(object.sessionID == crash.sessionID)
        #expect(object.appVersion == crash.appVersion)
    }

    @Test("Preserves sessionID captured at crash time, not the recovery session")
    func preservesCapturedSessionID() throws {
        // The "crashed" process snapshot carries its own sessionID. A fresh
        // UUID can never match the current session, so the recovery session
        // logCrash materializes keeps the captured ID intact.
        let crashedSessionID = UUID()
        let identity = Identity(install: UUID(), launch: UUID(), device: UUID(), session: Protected(crashedSessionID))
        let crash = CrashInfo(name: "SIGSEGV", reason: nil, stackTrace: [], identity: identity)

        #expect(Identity.stub.session.current != crashedSessionID)

        try logCrash(crash, deviceID: deviceID, context: context)

        let object = try #require(try context.fetchAll(CrashEntry.self).first)
        #expect(object.sessionID == crashedSessionID)
    }

    @Test("Encodes stack trace as JSON data")
    func encodesStackTrace() throws {
        let crash = makeCrashInfo(name: "SIGSEGV", reason: nil, stackTrace: ["main", "start"])

        try logCrash(crash, deviceID: deviceID, context: context)

        let object = try #require(try context.fetchAll(CrashEntry.self).first)

        let data = try #require(object.stackTrace)
        let decoded = try JSONDecoder().decode([String].self, from: data)
        #expect(decoded == ["main", "start"])
    }

    @Test("Handles nil reason")
    func handlesNilReason() throws {
        let crash = makeCrashInfo(name: "EXC_BAD_ACCESS", reason: nil, stackTrace: [])

        try logCrash(crash, deviceID: deviceID, context: context)

        let object = try #require(try context.fetchAll(CrashEntry.self).first)
        #expect(object.reason == nil)
    }

    @Test("Saves to the context")
    func savesToContext() throws {
        let crash = makeCrashInfo(name: "SIGBUS", reason: nil, stackTrace: [])

        try logCrash(crash, deviceID: deviceID, context: context)

        #expect(!context.hasChanges)
    }

    @Test("Skips crashes already logged under the same id")
    func skipsDuplicateID() throws {
        let crash = makeCrashInfo(name: "SIGSEGV", reason: nil, stackTrace: [])
        let id = UUID()

        try logCrash(crash, id: id, deviceID: deviceID, context: context)
        try logCrash(crash, id: id, deviceID: deviceID, context: context)

        #expect(try context.fetchAll(CrashEntry.self).count == 1)
    }
}
