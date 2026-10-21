//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorSupport
import Foundation
import ScoutDB

struct RetentionFold {
    let installs: [EntityRecord]
    let sessions: [SeriesPoint]
    let systems: [SeriesPoint]

    var installIDs: [DatedID] {
        installs.compactMap { record -> DatedID? in
            let date: Date? = record["date"]
            let install: String? = record["install_id"]
            guard let date, let install else {
                return nil
            }
            return DatedID(date: date, id: install)
        }
    }

    var installSessions: [InstallSession] {
        let devices = devices
        let systems = hourlySystems

        return sessions.filter { !$0.group.isEmpty }.map { point in
            InstallSession(
                install: point.group,
                date: point.date,
                os: devices[point.group].flatMap { systems[DeviceHour(device: $0, hour: point.date)] }
            )
        }
    }

    private var devices: [String: String] {
        installs.reduce(into: [:]) { devices, record in
            if let install: String = record["install_id"], let device: String = record["device_id"] {
                devices[install] = device
            }
        }
    }

    private var hourlySystems: [DeviceHour: String] {
        systems.reduce(into: [:]) { systems, point in
            guard let key = DeviceSystem(key: point.group) else {
                return
            }
            guard let system = key.system else {
                return
            }
            let hour = DeviceHour(device: key.device, hour: point.date)
            systems[hour] = systems[hour].map { min($0, system) } ?? system
        }
    }
}

private struct DeviceHour: Hashable {
    let device: String
    let hour: Date
}
