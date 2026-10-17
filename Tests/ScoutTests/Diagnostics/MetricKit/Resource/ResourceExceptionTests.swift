//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

@Suite("ResourceException")
struct ResourceExceptionTests {
    @Test("A record round-trips with its kind and stack")
    func roundTrip() throws {
        let original = ResourceException(
            name: "CPU Exception",
            fingerprint: "fp",
            reason: "92 s of CPU time in 180 s",
            stackTrace: ["0 MyApp 0x0 + 4096"],
            resourceKind: .cpu,
            date: Date(timeIntervalSince1970: 1_750_000_000),
            id: "r-1",
            deviceID: UUID(),
            installID: UUID(),
            launchID: UUID(),
            sessionID: UUID()
        )

        let decoded = try ResourceException(record: original.record)

        #expect(decoded.resourceKind == .cpu)
        #expect(decoded.stackTrace == original.stackTrace)
        #expect(decoded.fingerprint == "fp")
        #expect(decoded.sessionID == original.sessionID)
        #expect(decoded.date == original.date)
    }

    @Test("An unknown kind decodes as nil and a missing fingerprint is computed")
    func unknownKind() throws {
        var record = Record(recordType: ResourceEntry.recordType, recordID: "r-2")
        record["name"] = "CPU Exception"
        record["category"] = "gpu"

        let decoded = try ResourceException(record: record)

        #expect(decoded.resourceKind == nil)
        #expect(decoded.fingerprint == CrashFingerprint(name: "CPU Exception", reason: nil, stackTrace: []).value)
    }
}
