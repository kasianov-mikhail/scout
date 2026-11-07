//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

extension Crash: Fixture {
    static var sample: Crash {
        let name = "NSRangeException"
        let reason = "-[__NSArrayM objectAtIndex:]: index 4 beyond bounds [0 .. 2]"
        let stackTrace = [
            "0   CoreFoundation        0x0 __exceptionPreprocess + 164",
            "1   libobjc.A.dylib       0x0 objc_exception_throw + 60",
            "2   CoreFoundation        0x0 -[__NSArrayM objectAtIndex:] + 1228",
            "3   MyApp                 0x0 FeedViewController.row(at:) + 88",
            "4   MyApp                 0x0 FeedViewController.tableView(_:cellForRowAt:) + 152",
            "5   UIKitCore             0x0 -[UITableView _createPreparedCellForGlobalRow:withIndexPath:] + 512",
            "6   UIKitCore             0x0 -[UITableView _updateVisibleCellsNow:] + 304",
            "7   UIKitCore             0x0 -[UIView(CALayerDelegate) layoutSublayersOfLayer:] + 88",
            "8   QuartzCore            0x0 CA::Layer::layout_if_needed(CA::Transaction*) + 216",
            "9   CoreFoundation        0x0 __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__ + 24",
            "10  GraphicsServices      0x0 GSEventRunModal + 164",
            "11  UIKitCore             0x0 UIApplicationMain + 340",
            "12  MyApp                 0x0 main + 12",
        ]

        return Crash(
            name: name,
            fingerprint: CrashFingerprint(name: name, reason: reason, stackTrace: stackTrace).value,
            reason: reason,
            stackTrace: stackTrace,
            date: Date(),
            source: .inProcess,
            id: UUID().uuidString,
            deviceID: UUID(),
            installID: UUID(),
            launchID: UUID(),
            sessionID: UUID()
        )
    }

    static func sample(_ name: String, at date: Date, deviceID: UUID? = nil, sessionID: UUID? = nil) -> Crash {
        Crash(
            name: name,
            fingerprint: CrashFingerprint(name: name, reason: nil, stackTrace: []).value,
            reason: nil,
            stackTrace: [],
            date: date,
            source: .inProcess,
            id: UUID().uuidString,
            deviceID: deviceID,
            installID: nil,
            launchID: nil,
            sessionID: sessionID
        )
    }

    static func sample(source: IncidentSource) -> Crash {
        let name = "Watchdog Termination"
        let reason = "Namespace FRONTBOARD, Code 0x8badf00d"
        let stackTrace = [
            "0   libsystem_kernel.dylib   + 0x1234",
            "1   MyApp   + 0x1a2f0",
            "2   UIKitCore   + 0x1388",
            "3   MyApp   + 0x7d0",
        ]

        return Crash(
            name: name,
            fingerprint: CrashFingerprint(name: name, reason: reason, stackTrace: stackTrace).value,
            reason: reason,
            stackTrace: stackTrace,
            date: Date(),
            source: source,
            id: UUID().uuidString,
            deviceID: UUID(),
            installID: UUID(),
            launchID: UUID(),
            sessionID: UUID()
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

    static var sampleGroup: IncidentGroup<Crash> {
        let devices = (0..<8).map { _ in UUID() }
        let crashes = (0..<12).map { index in
            sample("NSRangeException", at: Date(), deviceID: devices[index % devices.count])
        }
        return IncidentGroup(id: crashes[0].fingerprint, records: crashes, symbol: nil)
    }
}
