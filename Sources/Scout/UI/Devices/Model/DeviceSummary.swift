//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct DeviceSummary: Identifiable, Equatable {
    let id: UUID
    let model: String
    let osVersion: String
    let lastSeen: Date
    let sessions: Int
    let crashes: Int
}

extension DeviceSummary {
    static func summaries(devices: [Record], sessions: [Record], crashes: [Record]) -> [DeviceSummary] {
        let sessionsByDevice = Dictionary(grouping: sessions.compactMap(SessionFields.init), by: \.deviceID)
        let crashCounts = Dictionary(crashes.compactMap { (record: Record) -> String? in record["device_id"] }.map { ($0, 1) }, uniquingKeysWith: +)

        return devices.compactMap { device -> DeviceSummary? in
            guard let deviceID: String = device["device_id"], let uuid = UUID(uuidString: deviceID), let model: String = device["model"] else {
                return nil
            }

            guard let latest = (sessionsByDevice[deviceID] ?? []).max(by: { $0.startDate < $1.startDate }) else {
                return nil
            }

            return DeviceSummary(
                id: uuid,
                model: model,
                osVersion: latest.osVersion,
                lastSeen: latest.startDate,
                sessions: sessionsByDevice[deviceID]?.count ?? 0,
                crashes: crashCounts[deviceID] ?? 0
            )
        }
    }

    private struct SessionFields {
        let deviceID: String
        let osVersion: String
        let startDate: Date

        init?(record: Record) {
            guard let deviceID: String = record["device_id"], let startDate: Date = record["start_date"] else {
                return nil
            }
            self.deviceID = deviceID
            osVersion = record["os_version"] ?? "—"
            self.startDate = startDate
        }
    }
}

extension DeviceSummary: Fixture {
    static let samples: [DeviceSummary] = [
        DeviceSummary(id: UUID(), model: "iPhone15,3", osVersion: "iOS 17.4", lastSeen: Date(timeIntervalSinceNow: -15 * 60), sessions: 812, crashes: 3),
        DeviceSummary(id: UUID(), model: "iPhone15,3", osVersion: "iOS 17.3", lastSeen: Date(timeIntervalSinceNow: -3 * 3600), sessions: 540, crashes: 0),
        DeviceSummary(id: UUID(), model: "iPhone14,2", osVersion: "iOS 17.4", lastSeen: Date(timeIntervalSinceNow: -6 * 3600), sessions: 391, crashes: 1),
        DeviceSummary(id: UUID(), model: "iPhone14,2", osVersion: "iOS 16.7", lastSeen: Date(timeIntervalSinceNow: -2 * 86400), sessions: 205, crashes: 0),
        DeviceSummary(id: UUID(), model: "iPhone13,2", osVersion: "iOS 17.3", lastSeen: Date(timeIntervalSinceNow: -1 * 86400), sessions: 178, crashes: 2),
        DeviceSummary(id: UUID(), model: "iPhone13,2", osVersion: "iOS 16.7", lastSeen: Date(timeIntervalSinceNow: -9 * 86400), sessions: 96, crashes: 0),
        DeviceSummary(id: UUID(), model: "iPad13,1", osVersion: "iOS 17.4", lastSeen: Date(timeIntervalSinceNow: -4 * 3600), sessions: 143, crashes: 0),
        DeviceSummary(id: UUID(), model: "iPad14,1", osVersion: "iOS 17.2", lastSeen: Date(timeIntervalSinceNow: -12 * 86400), sessions: 64, crashes: 1),
        DeviceSummary(id: UUID(), model: "iPhone12,1", osVersion: "iOS 16.7", lastSeen: Date(timeIntervalSinceNow: -30 * 86400), sessions: 22, crashes: 0),
    ]
}
