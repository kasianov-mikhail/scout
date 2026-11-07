//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

extension Hang: Fixture {
    static var sample: Hang {
        let name = "Main Thread Blocked"
        let reason = "-[NSJSONSerialization dataWithJSONObject:options:error:] on main thread"
        let stackTrace = [
            "0   libsystem_kernel.dylib 0x0 mach_msg2_trap + 8",
            "1   libsystem_kernel.dylib 0x0 mach_msg2_internal + 80",
            "2   Foundation            0x0 -[NSJSONSerialization dataWithJSONObject:options:error:] + 208",
            "3   MyApp                 0x0 FeedCache.write(_:) + 88",
            "4   MyApp                 0x0 FeedViewController.viewWillDisappear(_:) + 112",
            "5   UIKitCore             0x0 -[UIViewController _setViewAppearState:isAnimating:] + 524",
            "6   UIKitCore             0x0 -[UINavigationController _startDeferredTransitionIfNeeded:] + 612",
            "7   UIKitCore             0x0 -[UIView(CALayerDelegate) layoutSublayersOfLayer:] + 88",
            "8   QuartzCore            0x0 CA::Layer::layout_if_needed(CA::Transaction*) + 216",
            "9   CoreFoundation        0x0 __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__ + 24",
            "10  GraphicsServices      0x0 GSEventRunModal + 164",
            "11  UIKitCore             0x0 UIApplicationMain + 340",
            "12  MyApp                 0x0 main + 12",
        ]

        return Hang(
            name: name,
            fingerprint: CrashFingerprint(name: name, reason: nil, stackTrace: stackTrace).value,
            reason: reason,
            stackTrace: stackTrace,
            duration: 9.2,
            date: Date(),
            id: UUID().uuidString,
            deviceID: UUID(),
            installID: UUID(),
            launchID: UUID(),
            sessionID: UUID()
        )
    }

    static func sample(_ name: String, duration: TimeInterval, at date: Date, deviceID: UUID? = nil, sessionID: UUID? = nil) -> Hang {
        Hang(
            name: name,
            fingerprint: CrashFingerprint(name: name, reason: nil, stackTrace: []).value,
            reason: nil,
            stackTrace: [],
            duration: duration,
            date: date,
            id: UUID().uuidString,
            deviceID: deviceID,
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

    static var sampleGroup: IncidentGroup<Hang> {
        let devices = (0..<8).map { _ in UUID() }
        let hangs = (0..<9).map { index in
            sample("Main Thread Blocked", duration: 9.2, at: Date(), deviceID: devices[index % devices.count])
        }
        return IncidentGroup(id: hangs[0].fingerprint, records: hangs, symbol: nil)
    }
}
