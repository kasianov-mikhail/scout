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
        let sessions = try await store.query(SessionEntry.recordType).series(
            metric: .sum,
            group: "device_id",
            in: range
        )
        let devices = try await store.fetch(
            entity: DeviceEntry.recordType,
            uuids: Array(Set(sessions.filter(\.hasGroup).map(\.group)))
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
}
