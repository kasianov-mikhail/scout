//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import ScoutCore

@Suite("CrashFingerprint")
struct CrashFingerprintTests {
    @Test("Normalizes unstable addresses and frame numbers")
    func normalizesUnstableFrameParts() {
        let first = CrashFingerprint(
            name: "SIGABRT",
            reason: "Fatal error",
            stackTrace: [
                "0   MyApp 0x0000000101234567 functionA + 42",
                "1   MyApp 0x0000000107654321 functionB + 12",
            ]
        )
        let second = CrashFingerprint(
            name: "SIGABRT",
            reason: "Fatal error",
            stackTrace: [
                "14  MyApp 0x0000000109999999 functionA + 99",
                "15  MyApp 0x0000000108888888 functionB + 77",
            ]
        )

        #expect(first.value == second.value)
    }

    @Test("Separates different crash signatures")
    func separatesDifferentSignatures() {
        let first = CrashFingerprint(name: "SIGABRT", reason: "Fatal error", stackTrace: ["functionA"])
        let second = CrashFingerprint(name: "SIGSEGV", reason: "Fatal error", stackTrace: ["functionA"])
        let third = CrashFingerprint(name: "SIGABRT", reason: "Different error", stackTrace: ["functionA"])

        #expect(first.value != second.value)
        #expect(first.value != third.value)
    }

    @Test("Produces a SHA-256 hex digest")
    func producesSHA256HexDigest() {
        let fingerprint = CrashFingerprint(name: "SIGABRT", reason: nil, stackTrace: [])

        #expect(fingerprint.value.count == 64)
        #expect(fingerprint.value.allSatisfy { $0.isHexDigit && !$0.isUppercase })
    }
}
