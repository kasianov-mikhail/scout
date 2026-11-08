//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct DeviceModelSummary: Identifiable, Equatable {
    let model: String?
    let devices: Int
    let sessions: Int
    let crashes: Int
    let osRange: DeviceOSRange

    var id: String {
        model ?? ""
    }

    var name: String {
        model.map { DeviceModel(identifier: $0).name } ?? "Unknown"
    }

    var symbol: String {
        DeviceModel(identifier: model ?? "").symbol
    }

    var osLabel: String? {
        osRange.label
    }
}

extension [DeviceModelSummary] {
    init(activities: [DeviceActivity]) {
        self = Dictionary(grouping: activities, by: \.model)
            .map { model, activities in
                DeviceModelSummary(
                    model: model,
                    devices: activities.count,
                    sessions: activities.map(\.sessions).reduce(0, +),
                    crashes: activities.map(\.crashes).reduce(0, +),
                    osRange: DeviceOSRange(versions: activities.compactMap(\.osVersion))
                )
            }
            .sorted { lhs, rhs in
                lhs.sessions == rhs.sessions ? lhs.name < rhs.name : lhs.sessions > rhs.sessions
            }
    }
}

extension DeviceModelSummary: Fixture {
    static let samples: [DeviceModelSummary] = [
        DeviceModelSummary(
            model: "iPhone16,1",
            devices: 12,
            sessions: 4_100,
            crashes: 3,
            osRange: DeviceOSRange(versions: ["iOS 17.3", "iOS 17.4"])
        ),
        DeviceModelSummary(
            model: "iPhone14,5",
            devices: 9,
            sessions: 2_600,
            crashes: 1,
            osRange: DeviceOSRange(versions: ["iOS 16.7", "iOS 17.4"])
        ),
        DeviceModelSummary(
            model: "MacBookPro18,3",
            devices: 6,
            sessions: 1_900,
            crashes: 0,
            osRange: DeviceOSRange(versions: ["macOS 14.2", "macOS 14.4"])
        ),
        DeviceModelSummary(
            model: "iPhone13,2",
            devices: 7,
            sessions: 1_400,
            crashes: 2,
            osRange: DeviceOSRange(versions: ["iOS 16.7", "iOS 17.3"])
        ),
        DeviceModelSummary(
            model: "iPad13,1",
            devices: 4,
            sessions: 820,
            crashes: 0,
            osRange: DeviceOSRange(versions: ["iPadOS 17.4"])
        ),
        DeviceModelSummary(
            model: "MacBookAir10,1",
            devices: 3,
            sessions: 610,
            crashes: 1,
            osRange: DeviceOSRange(versions: ["macOS 14.4"])
        ),
    ]
}
