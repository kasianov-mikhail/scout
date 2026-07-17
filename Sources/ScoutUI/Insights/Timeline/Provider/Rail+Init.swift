//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import ScoutCore

extension Rail {
    init(
        device: Device, installs: [Install], launches: [Launch], sessions: [Session] = [], events: [Event] = [],
        crashes: [Crash] = []
    ) {
        let installs = Dictionary(grouping: installs, by: \.deviceID)
        let launches = Dictionary(grouping: launches, by: \.installID)
        let sessions = Dictionary(grouping: sessions, by: \.launchID)
        let events = Dictionary(grouping: events, by: \.sessionID)
        let crashes = Dictionary(grouping: crashes, by: \.sessionID)

        func installRoot(_ install: Install) -> InstallRoot {
            InstallRoot(
                install: install,
                launches: launches[install.installID]?.sorted(byDate: \.startDate).map(launchRoot) ?? []
            )
        }

        func launchRoot(_ launch: Launch) -> LaunchRoot {
            LaunchRoot(
                launch: launch,
                sessions: sessions[launch.launchID]?.sorted(byDate: \.startDate).map(sessionRoot) ?? []
            )
        }

        func sessionRoot(_ session: Session) -> SessionRoot {
            SessionRoot(
                session: session,
                events: events[session.sessionID]?.sorted(byDate: \.date) ?? [],
                crashes: crashes[session.sessionID]?.sorted(byDate: \.date) ?? []
            )
        }

        self.device = device
        self.installs = installs[device.deviceID]?.sorted(byDate: \.date).map(installRoot) ?? []
    }
}
