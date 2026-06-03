//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension TimelineItem {
    static func items(from rail: Rail) -> [TimelineItem] {
        var result: [TimelineItem] = []

        for install in rail.installs {
            for launch in install.launches {
                for session in launch.sessions {
                    for event in session.events.sorted(byDate: \.date) {
                        if let date = event.date {
                            result.append(
                                TimelineItem(
                                    id: event.id,
                                    name: event.name,
                                    date: date,
                                    active: [.install, .launch, .session],
                                    isCrash: false,
                                    installID: install.install.installID,
                                    launchID: launch.launch.launchID,
                                    sessionID: session.session.sessionID
                                )
                            )
                        }
                    }
                }
            }
        }

        return result
    }
}
