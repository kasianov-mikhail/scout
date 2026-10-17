//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension ResourceException: Fixture {
    static var sample: ResourceException {
        sample(kind: .cpu, at: Date())
    }

    static var samples: [ResourceException] {
        let now = Date()
        return [
            sample(kind: .cpu, at: now.addingTimeInterval(-3_600)),
            sample(kind: .cpu, at: now.addingTimeInterval(-86_400)),
            sample(kind: .diskWrite, at: now.addingTimeInterval(-2 * 86_400)),
        ]
    }

    static func sample(kind: ResourceKind, at date: Date) -> ResourceException {
        let name = kind == .cpu ? "CPU Exception" : "Disk Write Exception"
        let stackTrace = [
            "0   MyApp                 0x0000000100421000 + 4096",
            "1   Foundation            0x0000000180a12000 + 512",
            "2   libdispatch.dylib     0x0000000180170000 + 2048",
        ]

        return ResourceException(
            name: name,
            fingerprint: CrashFingerprint(name: name, reason: nil, stackTrace: stackTrace).value,
            reason: kind == .cpu ? "92 s of CPU time in 180 s" : "1024 MB written to disk",
            stackTrace: stackTrace,
            resourceKind: kind,
            date: date,
            id: UUID().uuidString,
            deviceID: UUID(),
            installID: UUID(),
            launchID: UUID(),
            sessionID: UUID()
        )
    }
}
