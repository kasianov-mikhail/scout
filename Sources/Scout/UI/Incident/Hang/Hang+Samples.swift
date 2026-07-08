//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Hang {
    static var sample: Hang {
        let name = "Main Thread Blocked"
        let reason = "-[NSJSONSerialization dataWithJSONObject:options:error:] on main thread"
        let stackTrace = [
            "0   Foundation            0x0 -[NSJSONSerialization dataWithJSONObject:options:error:] + 208",
            "1   Scout                 0x0 FeedViewController.reload(with:) + 152",
            "2   UIKitCore             0x0 -[UIViewController viewWillAppear:] + 88",
            "3   UIKitCore             0x0 -[UINavigationController _startTransition] + 1024",
        ]

        return Hang(
            name: name,
            fingerprint: CrashFingerprint(name: name, reason: reason, stackTrace: stackTrace).value,
            reason: reason,
            stackTrace: stackTrace,
            duration: 6.4,
            date: Date(),
            id: UUID().uuidString,
            deviceID: UUID(),
            installID: UUID(),
            launchID: UUID(),
            sessionID: UUID()
        )
    }

    static func sample(_ name: String, duration: TimeInterval, at date: Date, sessionID: UUID? = nil) -> Hang {
        Hang(
            name: name,
            fingerprint: CrashFingerprint(name: name, reason: nil, stackTrace: []).value,
            reason: nil,
            stackTrace: [],
            duration: duration,
            date: date,
            id: UUID().uuidString,
            deviceID: nil,
            installID: nil,
            launchID: nil,
            sessionID: sessionID
        )
    }

    static var samples: [Hang] {
        let entries: [(name: String, duration: TimeInterval, count: Int)] = [
            ("JSON Decode on Main Thread", 4.2, 6),
            ("Image Layout Pass", 9.8, 3),
            ("Watchdog Termination Imminent", 12.5, 2),
        ]

        var hangs: [Hang] = []
        var index = 0

        for entry in entries {
            for _ in 0..<entry.count {
                let date = Date(timeIntervalSinceNow: -Double(index % 13) * 86_400 - Double(index) * 600)
                hangs.append(.sample(entry.name, duration: entry.duration, at: date, sessionID: UUID()))
                index += 1
            }
        }

        return hangs
    }
}
