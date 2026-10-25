//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

struct DeviceFold {
    let sessions: [SeriesPoint]
    let systems: [SeriesPoint]
    let crashes: [SeriesPoint]
    let models: [String: String]

    var activities: [DeviceActivity] {
        let crashCounts = Dictionary(crashes.map { ($0.group, Int($0.value)) }, uniquingKeysWith: +)
        let latestSystems = latestSystems
        let sessions = sessions.filter(\.hasGroup)

        return Dictionary(grouping: sessions, by: \.group).compactMap { device, points in
            guard let lastSeen = points.map(\.date).max() else {
                return nil
            }

            return DeviceActivity(
                deviceID: device,
                model: models[device],
                osVersion: latestSystems[device],
                lastSeen: lastSeen,
                sessions: Int(points.map(\.value).reduce(0, +)),
                crashes: crashCounts[device] ?? 0
            )
        }
        .sorted { $0.deviceID < $1.deviceID }
    }

    private var latestSystems: [String: String] {
        var latest: [String: DatedSystem] = [:]

        for point in systems {
            guard let key = DeviceSystem(key: point.group) else {
                continue
            }
            guard let system = key.system else {
                continue
            }
            if let current = latest[key.device], current.date >= point.date {
                continue
            }
            latest[key.device] = DatedSystem(date: point.date, system: system)
        }

        return latest.mapValues(\.system)
    }
}

private struct DatedSystem {
    let date: Date
    let system: String
}
