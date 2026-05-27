//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension DeviceRail {
    static func tree(
        devices: [Device],
        installs: [Install],
        launches: [Launch],
        sessions: [Session],
        events: [Event],
        crashes: [Crash]
    ) -> [DeviceRail] {
        let installs = Dictionary(grouping: installs, by: \.deviceID)
        let launches = Dictionary(grouping: launches, by: \.installID)
        let sessions = Dictionary(grouping: sessions, by: \.launchID)
        let events = Dictionary(grouping: events, by: \.sessionID)
        let crashes = Dictionary(grouping: crashes, by: \.sessionID)

        func installRail(_ install: Install) -> InstallRail {
            InstallRail(
                install: install,
                launches: launches[install.installID]?.sorted(byDate: \.startDate).map(launchRail) ?? []
            )
        }

        func launchRail(_ launch: Launch) -> LaunchRail {
            LaunchRail(
                launch: launch,
                sessions: sessions[launch.launchID]?.sorted(byDate: \.startDate).map(sessionRail) ?? []
            )
        }

        func sessionRail(_ session: Session) -> SessionRail {
            SessionRail(
                session: session,
                events: events[session.sessionID]?.sorted(byDate: \.date) ?? [],
                crashes: crashes[session.sessionID]?.sorted(byDate: \.date) ?? []
            )
        }

        return devices.sorted(byDate: \.date).map { device in
            DeviceRail(
                device: device,
                installs: installs[device.deviceID]?.sorted(byDate: \.date).map(installRail) ?? []
            )
        }
    }
}

extension Array {
    fileprivate func sorted(byDate keyPath: KeyPath<Element, Date?>) -> [Element] {
        sorted { ($0[keyPath: keyPath] ?? .distantPast) < ($1[keyPath: keyPath] ?? .distantPast) }
    }
}
