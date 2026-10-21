//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension HTTPDatabase: DeviceReader {
    func devices(in range: Range<Date>) async throws -> [DeviceActivity] {
        let endpoint = URL(string: "api/v1/metrics/devices?" + range.queryParameters, relativeTo: url)

        return try await get(
            from: endpoint,
            reason: "Malformed metrics URL",
            as: DevicesResponse.self
        )
        .devices
        .map(DeviceActivity.init(device:))
    }

    func deviceCounts(in ranges: [Range<Date>]) async throws -> [Int] {
        guard !ranges.isEmpty else {
            return []
        }

        let list = ranges.map { "\($0.lowerBound.millisecondsSince1970)-\($0.upperBound.millisecondsSince1970)" }
        let endpoint = URL(string: "api/v1/metrics/device-counts?ranges=" + list.joined(separator: ","), relativeTo: url)

        return try await get(
            from: endpoint,
            reason: "Malformed metrics URL",
            as: DeviceCountsResponse.self
        )
        .counts
    }

    fileprivate struct DevicesResponse: Decodable {
        let devices: [Device]

        struct Device: Decodable {
            let deviceID: String
            let model: String?
            let osVersion: String?
            let lastSeen: Int64
            let sessions: Int
            let crashes: Int
        }
    }

    private struct DeviceCountsResponse: Decodable {
        let counts: [Int]
    }
}

extension DeviceActivity {
    fileprivate init(device: HTTPDatabase.DevicesResponse.Device) {
        self.init(
            deviceID: device.deviceID,
            model: device.model,
            osVersion: device.osVersion,
            lastSeen: Date(millisecondsSince1970: device.lastSeen),
            sessions: device.sessions,
            crashes: device.crashes
        )
    }
}
