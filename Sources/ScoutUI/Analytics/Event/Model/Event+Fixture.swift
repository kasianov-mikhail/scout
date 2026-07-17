//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutCore

extension Event: Fixture {
    static func sample(_ name: String, at date: Date, sessionID: UUID? = nil) -> Event {
        Event(
            name: name,
            level: nil,
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
        let names = ["app_launch", "screen_view", "button_tap", "purchase", "login", "logout"]
        return (0..<40).map { index in
            Event.sample(
                names[index % names.count],
                at: Date(timeIntervalSinceNow: -Double(index) * 1800),
                sessionID: UUID()
            )
        }
    }
}
