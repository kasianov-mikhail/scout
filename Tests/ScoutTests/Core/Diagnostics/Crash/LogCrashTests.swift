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
@Suite("logCrash")
struct LogCrashTests {
    let context = NSManagedObjectContext.inMemoryContext()

    private func makeCrashInfo(name: String, reason: String?, stackTrace: [String]) -> CrashInfo {
        CrashInfo(name: name, reason: reason, stackTrace: stackTrace)
    }

    @Test("Creates a CrashObject with correct fields")
    func createsCrashObject() throws {
        let crash = makeCrashInfo(name: "SIGABRT", reason: "Fatal error", stackTrace: ["frame0"])

        try logCrash(crash, context: context)

        let results = try context.fetchAll(CrashObject.self)

        #expect(results.count == 1)

        let object = try #require(results.first)
        let expectedFingerprint = CrashFingerprint(name: crash.name, reason: crash.reason, stackTrace: crash.stackTrace).value
        #expect(object.name == "SIGABRT")
        #expect(object.fingerprint == expectedFingerprint)
        #expect(object.reason == "Fatal error")
        #expect(object.date == crash.date)
        #expect(object.installID == crash.installID)
        #expect(object.launchID == crash.launchID)
        #expect(object.sessionID == crash.sessionID)
    }

    @Test("Preserves sessionID captured at crash time, not the recovery session")
    func preservesCapturedSessionID() throws {
        // The "crashed" process snapshot carries its own sessionID. A fresh
        // UUID can never match the recovery session that `awakeFromInsert`
        // assigns, so the test doesn't need to touch the `IDs.session`
        // global — other suites mutate it concurrently.
        let crashedSessionID = UUID()
        let crash = CrashInfo(name: "SIGSEGV", reason: nil, stackTrace: [], sessionID: crashedSessionID)

        #expect(IDs.session != crashedSessionID)

        try logCrash(crash, context: context)

        let object = try #require(try context.fetchAll(CrashObject.self).first)
        #expect(object.sessionID == crashedSessionID)
    }

    @Test("Encodes stack trace as JSON data")
    func encodesStackTrace() throws {
        let crash = makeCrashInfo(name: "SIGSEGV", reason: nil, stackTrace: ["main", "start"])

        try logCrash(crash, context: context)

        let object = try #require(try context.fetchAll(CrashObject.self).first)

        let data = try #require(object.stackTrace)
        let decoded = try JSONDecoder().decode([String].self, from: data)
        #expect(decoded == ["main", "start"])
    }

    @Test("Handles nil reason")
    func handlesNilReason() throws {
        let crash = makeCrashInfo(name: "EXC_BAD_ACCESS", reason: nil, stackTrace: [])

        try logCrash(crash, context: context)

        let object = try #require(try context.fetchAll(CrashObject.self).first)
        #expect(object.reason == nil)
    }

    @Test("Saves to the context")
    func savesToContext() throws {
        let crash = makeCrashInfo(name: "SIGBUS", reason: nil, stackTrace: [])

        try logCrash(crash, context: context)

        #expect(!context.hasChanges)
    }
}
