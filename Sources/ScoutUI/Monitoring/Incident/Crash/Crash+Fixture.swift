//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutCore

extension Crash: Fixture {
    static var sample: Crash {
        let name = "NSRangeException"
        let reason = "-[__NSArrayM objectAtIndex:]: index 4 beyond bounds [0 .. 2]"
        let stackTrace = [
            "0   CoreFoundation        0x0 __exceptionPreprocess + 164",
            "1   libobjc.A.dylib       0x0 objc_exception_throw + 60",
            "2   CoreFoundation        0x0 -[__NSArrayM objectAtIndex:] + 1228",
            "3   Scout                 0x0 FeedViewController.row(at:) + 88",
        ]

        return Crash(
            name: name,
            fingerprint: CrashFingerprint(name: name, reason: reason, stackTrace: stackTrace).value,
            reason: reason,
            stackTrace: stackTrace,
            date: Date(),
            id: UUID().uuidString,
            deviceID: UUID(),
            installID: UUID(),
            launchID: UUID(),
            sessionID: UUID()
        )
    }

    static func sample(_ name: String, at date: Date, sessionID: UUID? = nil) -> Crash {
        Crash(
            name: name,
            fingerprint: CrashFingerprint(name: name, reason: nil, stackTrace: []).value,
            reason: nil,
            stackTrace: [],
            date: date,
            id: UUID().uuidString,
            deviceID: nil,
            installID: nil,
            launchID: nil,
            sessionID: sessionID
        )
    }

    static var samples: [Crash] {
        let counts: KeyValuePairs<String, Int> = ["NSRangeException": 8, "Fatal error": 4, "SIGSEGV": 2]

        var crashes: [Crash] = []
        var index = 0

        for (name, count) in counts {
            for _ in 0..<count {
                let date = Date(timeIntervalSinceNow: -Double(index % 13) * 86_400 - Double(index) * 600)
                crashes.append(.sample(name, at: date, sessionID: UUID()))
                index += 1
            }
        }

        return crashes
    }
}
