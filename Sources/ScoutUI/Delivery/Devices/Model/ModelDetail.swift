//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct ModelDetail: Equatable {
    let devices: [DeviceSummary]
    let osVersions: [DeviceOSUsage]

    var deviceCount: Int {
        devices.count
    }

    var sessionCount: Int {
        devices.map(\.sessions).reduce(0, +)
    }

    var crashCount: Int {
        devices.map(\.crashes).reduce(0, +)
    }

    var maxSessions: Int {
        devices.map(\.sessions).max() ?? 0
    }
}

struct DeviceOSUsage: Identifiable, Equatable {
    let version: String
    let devices: Int
    let sessions: Int
    let percentage: Int

    var id: String {
        version
    }

    var percentageText: String {
        "\(percentage)%"
    }
}

extension ModelDetail {
    init(model: String?, activities: [DeviceActivity]) {
        let devices =
            activities
            .compactMap(DeviceSummary.init(activity:))
            .filter { $0.model == model }
            .sorted { $0.lastSeen > $1.lastSeen }

        let sessions = devices.map(\.sessions).reduce(0, +)
        let osVersions = Dictionary(grouping: devices, by: \.osVersion)
            .map { version, devices in
                let versionSessions = devices.map(\.sessions).reduce(0, +)
                let percentage = sessions > 0 ? Int((Double(versionSessions) / Double(sessions) * 100).rounded()) : 0

                return DeviceOSUsage(
                    version: version,
                    devices: devices.count,
                    sessions: versionSessions,
                    percentage: percentage
                )
            }
            .sorted { lhs, rhs in
                lhs.sessions == rhs.sessions ? lhs.version > rhs.version : lhs.sessions > rhs.sessions
            }

        self.init(devices: devices, osVersions: osVersions)
    }
}

extension ModelDetail {
    static var sample: ModelDetail {
        ModelDetail(
            devices: DeviceSummary.samples,
            osVersions: [
                DeviceOSUsage(version: "iOS 17.4", devices: 6, sessions: 3_100, percentage: 74),
                DeviceOSUsage(version: "iOS 17.3", devices: 3, sessions: 1_100, percentage: 26),
            ]
        )
    }
}
