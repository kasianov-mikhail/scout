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
@Suite("LogCrash")
struct LogCrashTests {
    let context = NSManagedObjectContext.inMemoryContext()

    @Test("logCrash persists crash info to Core Data")
    func testLogCrashPersists() throws {
        let crash = CrashInfo(
            name: "TestException",
            reason: "Something went wrong",
            stackTrace: ["frame1", "frame2"]
        )

        try logCrash(crash, context: context)

        let request = NSFetchRequest<CrashObject>(entityName: "CrashObject")
        let results = try context.fetch(request)

        #expect(results.count == 1)

        let object = results[0]
        #expect(object.name == "TestException")
        #expect(object.reason == "Something went wrong")
        #expect(object.crashID != nil)
        #expect(object.date == crash.date)
    }

    @Test("logCrash encodes stack trace as JSON")
    func testLogCrashEncodesStackTrace() throws {
        let crash = CrashInfo(
            name: "SIGABRT",
            reason: nil,
            stackTrace: ["0x1234", "0x5678"]
        )

        try logCrash(crash, context: context)

        let request = NSFetchRequest<CrashObject>(entityName: "CrashObject")
        let object = try #require(try context.fetch(request).first)
        let data = try #require(object.stackTrace)
        let decoded = try JSONDecoder().decode([String].self, from: data)

        #expect(decoded == ["0x1234", "0x5678"])
    }

    @Test("logCrash overrides IDs from crash info")
    func testLogCrashOverridesIDs() throws {
        let crash = CrashInfo(
            name: "TestCrash",
            reason: nil,
            stackTrace: []
        )

        try logCrash(crash, context: context)

        let request = NSFetchRequest<CrashObject>(entityName: "CrashObject")
        let object = try #require(try context.fetch(request).first)

        #expect(object.userID == crash.userID)
        #expect(object.launchID == crash.launchID)
    }

    @Test("logCrash handles nil reason")
    func testLogCrashNilReason() throws {
        let crash = CrashInfo(
            name: "NilReason",
            reason: nil,
            stackTrace: []
        )

        try logCrash(crash, context: context)

        let request = NSFetchRequest<CrashObject>(entityName: "CrashObject")
        let object = try #require(try context.fetch(request).first)

        #expect(object.reason == nil)
    }
}
