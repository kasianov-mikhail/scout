//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import ScoutDB

extension NativeDatabase: DeviceReader {
    func devices(in range: Range<Date>) async throws -> [DeviceActivity] {
        let store = try await resolve()

        async let sessions = store.query(SessionEntry.recordType).series(
            metric: .sum,
            group: "device_id",
            in: range
        )
        async let systems = store.query(SessionEntry.recordType).series(
            metric: .sum,
            group: CatalogEntry.deviceSystem,
            in: range
        )
        async let crashes = store.query(CrashEntry.recordType).series(
            metric: .sum,
            group: "device_id",
            in: range
        )
        async let devices = store.records(
            entity: DeviceEntry.recordType,
            dateField: "date",
            fields: ["date", "device_id", "model"],
            in: .distantPast..<range.upperBound
        )

        return try await DeviceFold(
            sessions: sessions,
            systems: systems,
            crashes: crashes,
            models: devices.reduce(into: [:]) { models, record in
                if let device: String = record["device_id"], let model: String = record["model"] {
                    models[device] = model
                }
            }
        )
        .activities
    }

    func deviceCounts(in ranges: [Range<Date>]) async throws -> [Int] {
        guard let lower = ranges.map(\.lowerBound).min() else {
            return []
        }
        guard let upper = ranges.map(\.upperBound).max() else {
            return []
        }

        let store = try await resolve()
        let points = try await store.query(SessionEntry.recordType).series(
            metric: .sum,
            group: "device_id",
            in: lower..<upper
        )

        return ranges.map { range in
            Set(points.filter { range.contains($0.date) }.map(\.group)).count
        }
    }
}
