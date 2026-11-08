//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Rail {
    init(device: Device, installs: [Install], launches: [Launch], sessions: [Session] = [], events: [Event] = [], crashes: [Crash] = []) {
        let launches = Dictionary(grouping: launches + syntheticLaunches(launches: launches, sessions: sessions), by: \.installID)
        let installs = Dictionary(grouping: installs, by: \.deviceID)
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

private func syntheticLaunches(launches: [Launch], sessions: [Session]) -> [Launch] {
    let delivered = Set(launches.compactMap(\.launchID))
    var orphans: [UUID: [Session]] = [:]
    for session in sessions {
        guard let launchID = session.launchID, !delivered.contains(launchID) else {
            continue
        }
        orphans[launchID, default: []].append(session)
    }

    return orphans.map { launchID, sessions in
        Launch(
            startDate: sessions.compactMap(\.startDate).min(),
            endDate: nil,
            id: launchID.uuidString,
            launchID: launchID,
            installID: sessions.first?.installID
        )
    }
}
