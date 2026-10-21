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
@testable import Support

@MainActor
@Suite("CrashInfo.log")
struct LogCrashTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let deviceID = UUID()

    private func makeCrashInfo(name: String, reason: String?, stackTrace: [String]) -> CrashInfo {
        CrashInfo(name: name, reason: reason, stackTrace: stackTrace, backtrace: Backtrace(images: [], threads: []), identity: .stub)
    }

    @Test("Creates a CrashEntry with correct fields")
    func createsCrashObject() throws {
        let crash = makeCrashInfo(name: "SIGABRT", reason: "Fatal error", stackTrace: ["frame0"])

        try crash.log(deviceID: deviceID, context: context)

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
        // log materializes keeps the captured ID intact.
        let crashedSessionID = UUID()
        let identity = Identity(install: UUID(), launch: UUID(), device: UUID(), session: Protected(crashedSessionID))
        let crash = CrashInfo(name: "SIGSEGV", reason: nil, stackTrace: [], backtrace: Backtrace(images: [], threads: []), identity: identity)

        #expect(Identity.stub.session.current != crashedSessionID)

        try crash.log(deviceID: deviceID, context: context)

        let object = try #require(try context.fetchAll(CrashEntry.self).first)
        #expect(object.sessionID == crashedSessionID)
    }

    @Test("Stores the backtrace for delivery under the crash id")
    func storesBacktrace() throws {
        let id = UUID()
        let backtrace = Backtrace(addresses: [0x1010], images: [LoadedImage(name: "MyApp", base: 0x1000, size: 0x100, uuid: UUID())])
        let crash = CrashInfo(name: "SIGSEGV", reason: nil, stackTrace: [], backtrace: backtrace, identity: .stub)

        try crash.log(id: id, deviceID: deviceID, context: context)
        try crash.log(id: id, deviceID: deviceID, context: context)

        let entries = try context.fetchAll(BacktraceEntry.self)
        let entry = try #require(entries.first)
        #expect(entries.count == 1)
        #expect(entry.incidentID == id)
        #expect(entry.date == crash.date)
        #expect(try JSONDecoder().decode(Backtrace.self, from: entry.payload) == backtrace)
    }

    @Test("A crash archived before backtraces stores none")
    func noBacktrace() throws {
        let crash = CrashInfo(
            name: "SIGSEGV",
            reason: nil,
            stackTrace: [],
            backtrace: nil,
            date: Date(),
            installID: UUID(),
            launchID: UUID(),
            sessionID: UUID(),
            appVersion: nil
        )

        try crash.log(deviceID: deviceID, context: context)

        #expect(try context.fetchAll(CrashEntry.self).count == 1)
        #expect(try context.fetchAll(BacktraceEntry.self).isEmpty)
    }

    @Test("Encodes stack trace as JSON data")
    func encodesStackTrace() throws {
        let crash = makeCrashInfo(name: "SIGSEGV", reason: nil, stackTrace: ["main", "start"])

        try crash.log(deviceID: deviceID, context: context)

        let object = try #require(try context.fetchAll(CrashEntry.self).first)

        let data = try #require(object.stackTrace)
        let decoded = try JSONDecoder().decode([String].self, from: data)
        #expect(decoded == ["main", "start"])
    }

    @Test("Handles nil reason")
    func handlesNilReason() throws {
        let crash = makeCrashInfo(name: "EXC_BAD_ACCESS", reason: nil, stackTrace: [])

        try crash.log(deviceID: deviceID, context: context)

        let object = try #require(try context.fetchAll(CrashEntry.self).first)
        #expect(object.reason == nil)
    }

    @Test("Saves to the context")
    func savesToContext() throws {
        let crash = makeCrashInfo(name: "SIGBUS", reason: nil, stackTrace: [])

        try crash.log(deviceID: deviceID, context: context)

        #expect(!context.hasChanges)
    }

    @Test("Skips crashes already logged under the same id")
    func skipsDuplicateID() throws {
        let crash = makeCrashInfo(name: "SIGSEGV", reason: nil, stackTrace: [])
        let id = UUID()

        try crash.log(id: id, deviceID: deviceID, context: context)
        try crash.log(id: id, deviceID: deviceID, context: context)

        #expect(try context.fetchAll(CrashEntry.self).count == 1)
    }

    @Test("Marks the install as crashed on the crash's version")
    func marksCrashedInstall() throws {
        let crash = CrashInfo(
            name: "SIGSEGV",
            reason: nil,
            stackTrace: [],
            backtrace: nil,
            date: Date(),
            installID: UUID(),
            launchID: UUID(),
            sessionID: UUID(),
            appVersion: "2.0"
        )

        try crash.log(deviceID: deviceID, context: context)

        let marker = try #require(context.fetchAll(FirstSeenEntry.self).first)
        #expect(marker.name == Version.crashMarker)
        #expect(marker.appVersion == "2.0")
        #expect(marker.install?.installID == crash.installID)
    }

    @Test("Marks a crash in a new install's first month for its retention cohort")
    func marksRetentionCrash() throws {
        let crash = makeCrashInfo(name: "SIGSEGV", reason: nil, stackTrace: [])

        try crash.log(deviceID: deviceID, context: context)

        let names = Set(try context.fetchAll(RetentionMarkEntry.self).map(\.name))
        #expect(names == ["install", "crash"])
    }
}
