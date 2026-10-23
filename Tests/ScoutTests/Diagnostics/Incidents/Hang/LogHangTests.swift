//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation
import SymbolTable
import Testing

@testable import Scout
@testable import Support

@MainActor
@Suite("HangInfo.log")
struct LogHangTests {
    let context = NSManagedObjectContext.inMemoryContext()
    let deviceID = UUID()

    private func makeHangInfo(name: String, reason: String?, stackTrace: [String], duration: TimeInterval) -> HangInfo {
        HangInfo(name: name, reason: reason, stackTrace: stackTrace, backtrace: Backtrace(images: [], threads: []), duration: duration, identity: .stub)
    }

    @Test("Creates a HangEntry with correct fields")
    func createsHangObject() throws {
        let hang = makeHangInfo(
            name: "Main Thread Blocked", reason: "Main thread unresponsive for 4.2s", stackTrace: ["frame0"],
            duration: 4.2)

        try hang.log(deviceID: deviceID, context: context)

        let results = try context.fetchAll(HangEntry.self)

        #expect(results.count == 1)

        let object = try #require(results.first)
        let expectedFingerprint = CrashFingerprint(name: hang.name, reason: nil, stackTrace: hang.stackTrace).value
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

    @Test("Hangs with the same stack share a fingerprint despite differing durations")
    func sharesFingerprintAcrossDurations() throws {
        let first = makeHangInfo(
            name: "Main Thread Blocked", reason: "Main thread unresponsive for 3.2s", stackTrace: ["frame0"],
            duration: 3.2)
        let second = makeHangInfo(
            name: "Main Thread Blocked", reason: "Main thread unresponsive for 5.7s", stackTrace: ["frame0"],
            duration: 5.7)

        try first.log(deviceID: deviceID, context: context)
        try second.log(deviceID: deviceID, context: context)

        let fingerprints = try context.fetchAll(HangEntry.self).map(\.fingerprint)
        #expect(fingerprints.count == 2)
        #expect(Set(fingerprints).count == 1)
    }

    @Test("Hangs at different sites of a stripped build get fingerprints that decoding keeps")
    func symbolicatedSitesStayApart() throws {
        let uuid = UUID()
        let image = LoadedImage(name: "MyApp", base: 0x10_0000, size: 0x1000, uuid: uuid)
        let symbols = SymbolTable(
            uuid: uuid,
            functions: [
                SymbolTable.Function(start: 0x100, end: 0x200, name: "alpha"),
                SymbolTable.Function(start: 0x200, end: 0x300, name: "beta"),
            ],
            lines: [],
            inlines: []
        )
        let hangs = [UInt64(0x110), 0x210].map { offset in
            HangInfo(
                name: "Main Thread Blocked",
                reason: nil,
                stackTrace: ["0   MyApp   0x\(String(image.base + offset, radix: 16)) __mh_execute_header + \(offset)"],
                backtrace: Backtrace(addresses: [image.base + offset], images: [image]),
                duration: 3.5,
                identity: .stub
            )
        }

        #expect(hangs[0].fingerprint == hangs[1].fingerprint)

        for hang in hangs {
            try hang.symbolicated(symbols: symbols).log(deviceID: deviceID, context: context)
        }

        let entries = try context.fetchAll(HangEntry.self)
        let fingerprints = entries.compactMap(\.fingerprint)
        #expect(Set(fingerprints).count == 2)
        #expect(try entries.map { try Hang(record: $0.record).fingerprint } == fingerprints)
    }

    @Test("Preserves sessionID captured at hang time, not the recovery session")
    func preservesCapturedSessionID() throws {
        let hangSessionID = UUID()
        let identity = Identity(install: UUID(), launch: UUID(), device: UUID(), session: Protected(hangSessionID))
        let hang = HangInfo(name: "Main Thread Blocked", reason: nil, stackTrace: [], backtrace: Backtrace(images: [], threads: []), duration: 3.5, identity: identity)

        #expect(Identity.stub.session.current != hangSessionID)

        try hang.log(deviceID: deviceID, context: context)

        let object = try #require(try context.fetchAll(HangEntry.self).first)
        #expect(object.sessionID == hangSessionID)
    }

    @Test("Encodes stack trace as JSON data")
    func encodesStackTrace() throws {
        let hang = makeHangInfo(name: "Main Thread Blocked", reason: nil, stackTrace: ["main", "start"], duration: 3.5)

        try hang.log(deviceID: deviceID, context: context)

        let object = try #require(try context.fetchAll(HangEntry.self).first)

        let data = try #require(object.stackTrace)
        let decoded = try JSONDecoder().decode([String].self, from: data)
        #expect(decoded == ["main", "start"])
    }

    @Test("Handles nil reason")
    func handlesNilReason() throws {
        let hang = makeHangInfo(name: "Main Thread Blocked", reason: nil, stackTrace: [], duration: 3.5)

        try hang.log(deviceID: deviceID, context: context)

        let object = try #require(try context.fetchAll(HangEntry.self).first)
        #expect(object.reason == nil)
    }

    @Test("Saves to the context")
    func savesToContext() throws {
        let hang = makeHangInfo(name: "Main Thread Blocked", reason: nil, stackTrace: [], duration: 3.5)

        try hang.log(deviceID: deviceID, context: context)

        #expect(!context.hasChanges)
    }

    @Test("Skips hangs already logged under the same id")
    func skipsDuplicateID() throws {
        let hang = makeHangInfo(name: "Main Thread Blocked", reason: nil, stackTrace: [], duration: 3.5)
        let id = UUID()

        try hang.log(id: id, deviceID: deviceID, context: context)
        try hang.log(id: id, deviceID: deviceID, context: context)

        #expect(try context.fetchAll(HangEntry.self).count == 1)
    }
}
