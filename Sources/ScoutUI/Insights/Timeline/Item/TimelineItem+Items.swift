//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutCore

extension TimelineItem {
    static func items(from rail: Rail) -> [TimelineItem] {
        rail.installs.flatMap { install in
            install.launches.flatMap { launch in
                launch.sessions.flatMap { session in
                    session.events.compactMap { event in
                        event.date.map { date in
                            TimelineItem(
                                id: event.id,
                                name: event.name,
                                date: date,
                                active: [.install, .launch, .session],
                                installID: install.install.installID,
                                launchID: launch.launch.launchID,
                                sessionID: session.session.sessionID
                            )
                        }
                    }
                }
            }
        }
    }
}
