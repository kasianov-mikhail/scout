//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension [DeviceActivity] {
    package init(devices: [Record], sessions: [Record], crashes: [Record]) {
        let visits = Dictionary(grouping: sessions.compactMap(DeviceVisit.init), by: \.device)
        let crashCounts = Dictionary(crashes.compactMap { (record: Record) -> String? in record["device_id"] }.map { ($0, 1) }, uniquingKeysWith: +)
        let models: [String: String] = devices.reduce(into: [:]) { models, device in
            if let id: String = device["device_id"], let model: String = device["model"] {
                models[id] = model
            }
        }

        self = visits.compactMap { device, visits -> DeviceActivity? in
            guard let latest = visits.max(by: { $0.date < $1.date }) else {
                return nil
            }

            return DeviceActivity(
                deviceID: device,
                model: models[device],
                osVersion: latest.system,
                lastSeen: latest.date,
                sessions: visits.count,
                crashes: crashCounts[device] ?? 0
            )
        }
        .sorted { $0.deviceID < $1.deviceID }
    }
}

extension [Record] {
    package func deviceCounts(in ranges: [Range<Date>]) -> [Int] {
        let visits = compactMap(DeviceVisit.init)

        return ranges.map { range in
            Set(visits.filter { range.contains($0.date) }.map(\.device)).count
        }
    }
}

private struct DeviceVisit {
    let device: String
    let system: String?
    let date: Date

    init?(record: Record) {
        let device: String? = record["device_id"]
        let date: Date? = record["start_date"]

        guard let device, let date else {
            return nil
        }

        self.device = device
        self.system = record["os_version"]
        self.date = date
    }
}
