//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension SessionTimeline {
    static var sample: SessionTimeline {
        let start = Date(timeIntervalSince1970: 1_761_403_200)
        let event = { (name: String, level: EventLevel?, offset: TimeInterval) in
            Event(
                name: name,
                level: level,
                date: start.addingTimeInterval(offset),
                paramCount: nil,
                uuid: UUID(),
                id: UUID().uuidString,
                installID: nil,
                sessionID: nil,
                deviceID: nil
            )
        }
        let events = [
            event("app_open", nil, 0),
            event("search", nil, 39),
            event("add_to_cart", nil, 173),
            event("payment_retry", .warning, 409),
            event("payment_failed", .error, 427),
            event("order_state_invalid", .critical, 731),
        ]
        let screen = { (name: String, offset: TimeInterval, duration: TimeInterval) in
            Screen(
                name: name,
                previous: nil,
                startDate: start.addingTimeInterval(offset),
                endDate: start.addingTimeInterval(offset + duration),
                id: UUID().uuidString,
                sessionID: nil
            )
        }
        let screens = [
            screen("Home", 1, 67),
            screen("ProductDetail", 68, 130),
            screen("Checkout", 198, 230),
            screen("PaymentError", 428, 304),
        ]
        let hang = Hang(
            name: "Main Thread Blocked",
            fingerprint: "hang",
            reason: nil,
            stackTrace: [],
            duration: 9.2,
            date: start.addingTimeInterval(70),
            id: "a-hang",
            deviceID: nil,
            installID: nil,
            launchID: nil,
            sessionID: nil
        )
        let resource = ResourceException(
            name: "CPU Exception",
            fingerprint: "cpu",
            reason: "92 s of CPU time in 180 s",
            stackTrace: [],
            resourceKind: .cpu,
            date: start.addingTimeInterval(732),
            id: "c-resource",
            deviceID: nil,
            installID: nil,
            launchID: nil,
            sessionID: nil
        )
        let crash = Crash(
            name: "NSRangeException",
            fingerprint: "crash",
            reason: nil,
            stackTrace: [],
            date: start.addingTimeInterval(732),
            source: .inProcess,
            id: "b-crash",
            deviceID: nil,
            installID: nil,
            launchID: nil,
            sessionID: nil
        )

        return SessionTimeline(
            info: .sample,
            events: events,
            screens: screens,
            crashes: [crash],
            hangs: [hang],
            resources: [resource],
            now: start.addingTimeInterval(732)
        )
    }
}
