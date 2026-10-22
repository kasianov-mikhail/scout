//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension CachingDatabase: DeviceReader {
    func devices(in range: Range<Date>) async throws -> [DeviceActivity] {
        let lowerWeek = range.lowerBound.startOfWeek
        let frozenLower = lowerWeek == range.lowerBound ? lowerWeek : lowerWeek.addingWeek(1)
        let frozenUpper = min(range.upperBound, now().startOfWeek.addingWeek(-1))

        guard frozenLower < frozenUpper else {
            return try await base.devices(in: range)
        }

        async let head = liveDevices(in: range.lowerBound..<frozenLower)
        async let tail = liveDevices(in: frozenUpper..<range.upperBound)
        let frozen = try await frozenDevices(in: frozenLower..<frozenUpper)

        return try await [DeviceActivity](merging: [head, frozen, tail])
    }

    func deviceCounts(in ranges: [Range<Date>]) async throws -> [Int] {
        try await base.deviceCounts(in: ranges)
    }

    private func liveDevices(in range: Range<Date>) async throws -> [DeviceActivity] {
        guard !range.isEmpty else { return [] }
        return try await base.devices(in: range)
    }

    private func frozenDevices(in frozen: Range<Date>) async throws -> [DeviceActivity] {
        let fingerprint = [scope, "devices"].joined(separator: "|")
        let cached = await cachedDevices(for: fingerprint, in: frozen)
        let cachedUpper = cached?.upper ?? frozen.lowerBound
        let devices = cached?.records.compactMap(DeviceActivity.init(record:)) ?? []

        guard cachedUpper < frozen.upperBound else {
            return devices
        }

        let fetched = try await base.devices(in: cachedUpper..<frozen.upperBound)
        let merged = [DeviceActivity](merging: [devices, fetched])
        await cache.replace(merged.map(\.record), for: fingerprint, covering: frozen)
        return merged
    }

    private func cachedDevices(for fingerprint: String, in frozen: Range<Date>) async -> CoveredSpan? {
        guard let covered = await cache.coveredRange(for: fingerprint) else {
            return nil
        }
        guard covered.lowerBound == frozen.lowerBound, covered.upperBound <= frozen.upperBound else {
            return nil
        }
        guard let records = await cache.records(for: fingerprint, in: covered) else {
            return nil
        }
        return CoveredSpan(records: records, upper: covered.upperBound)
    }
}

extension [DeviceActivity] {
    fileprivate init(merging parts: [[DeviceActivity]]) {
        var merged: [String: DeviceActivity] = [:]

        for activity in parts.joined() {
            guard let current = merged[activity.deviceID] else {
                merged[activity.deviceID] = activity
                continue
            }

            merged[activity.deviceID] = DeviceActivity(
                deviceID: activity.deviceID,
                model: activity.model ?? current.model,
                osVersion: activity.osVersion ?? current.osVersion,
                lastSeen: Swift.max(current.lastSeen, activity.lastSeen),
                sessions: current.sessions + activity.sessions,
                crashes: current.crashes + activity.crashes
            )
        }

        self = merged.values.sorted { $0.deviceID < $1.deviceID }
    }
}

extension DeviceActivity {
    fileprivate init?(record: Record) {
        let deviceID: String? = record["device_id"]
        let lastSeen: Date? = record["date"]
        let sessions: Int? = record["sessions"]
        let crashes: Int? = record["crashes"]

        guard let deviceID, let lastSeen, let sessions, let crashes else {
            return nil
        }

        self.init(
            deviceID: deviceID,
            model: record["model"],
            osVersion: record["os_version"],
            lastSeen: lastSeen,
            sessions: sessions,
            crashes: crashes
        )
    }

    fileprivate var record: Record {
        var record = Record(recordType: "DeviceActivity", recordID: UUID().uuidString)
        record["date"] = lastSeen
        record["device_id"] = deviceID
        record["model"] = model
        record["os_version"] = osVersion
        record["sessions"] = sessions
        record["crashes"] = crashes
        return record
    }
}
