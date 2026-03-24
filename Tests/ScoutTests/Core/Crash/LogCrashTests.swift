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

        let request = NSFetchRequest<CrashObject>(entityName: "CrashObject")
        let results = try context.fetch(request)

        #expect(results.count == 1)

        let object = try #require(results.first)
        #expect(object.name == "SIGABRT")
        #expect(object.reason == "Fatal error")
        #expect(object.date == crash.date)
        #expect(object.crashID != nil)
        #expect(object.value(forKey: "userID") as? UUID == crash.userID)
        #expect(object.value(forKey: "launchID") as? UUID == crash.launchID)
    }

    @Test("Encodes stack trace as JSON data")
    func encodesStackTrace() throws {
        let crash = makeCrashInfo(name: "SIGSEGV", reason: nil, stackTrace: ["main", "start"])

        try logCrash(crash, context: context)

        let request = NSFetchRequest<CrashObject>(entityName: "CrashObject")
        let object = try #require(try context.fetch(request).first)

        let data = try #require(object.stackTrace)
        let decoded = try JSONDecoder().decode([String].self, from: data)
        #expect(decoded == ["main", "start"])
    }

    @Test("Handles nil reason")
    func handlesNilReason() throws {
        let crash = makeCrashInfo(name: "EXC_BAD_ACCESS", reason: nil, stackTrace: [])

        try logCrash(crash, context: context)

        let request = NSFetchRequest<CrashObject>(entityName: "CrashObject")
        let object = try #require(try context.fetch(request).first)
        #expect(object.reason == nil)
    }

    @Test("Saves to the context")
    func savesToContext() throws {
        let crash = makeCrashInfo(name: "SIGBUS", reason: nil, stackTrace: [])

        try logCrash(crash, context: context)

        #expect(!context.hasChanges)
    }
}
