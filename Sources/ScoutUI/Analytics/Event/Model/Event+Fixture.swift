//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Event: Fixture {
    static func sample(_ name: String, at date: Date, level: EventLevel? = nil, sessionID: UUID? = nil) -> Event {
        Event(
            name: name,
            level: level,
            date: date,
            paramCount: nil,
            uuid: nil,
            id: UUID().uuidString,
            installID: nil,
            sessionID: sessionID,
            deviceID: nil
        )
    }

    static var samples: [Event] {
        let names = ["screen_view", "button_tap", "purchase", "payment_retry", "login", "app_launch"]
        let levels: [EventLevel?] = [nil, nil, .notice, .warning, nil, .error, nil, .critical]
        return (0..<40).map { index in
            Event.sample(
                names[index % names.count],
                at: Date(timeIntervalSinceNow: -Double(index) * 1800),
                level: levels[index % levels.count],
                sessionID: UUID()
            )
        }
    }
}
