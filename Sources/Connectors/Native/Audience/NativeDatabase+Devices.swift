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
        let storage = try await resolveStorage()

        async let systems = deviceSystems(in: range, storage: storage)
        async let crashes = deviceCrashes(in: range, store: storage.store)

        let sessions = try await deviceSessions(in: range, store: storage.store)
        let models = try await deviceModels(for: sessions, store: storage.store)

        return try await DeviceFold(
            sessions: sessions,
            systems: systems,
            crashes: crashes,
            models: models
        )
        .activities
    }

    private func deviceSystems(in range: Range<Date>, storage: Storage) async throws -> [SeriesPoint] {
        let entity = SessionEntry.recordType
        let group = CatalogEntry.deviceSystem
        let schema = try await storage.registry.schema(for: entity)

        guard schema.aggregates.contains(where: { $0.group == group && $0.field == nil && $0.bounds == nil }) else {
            return []
        }

        return try await storage.store.query(entity).series(
            metric: .sum,
            group: group,
            range: range
        )
    }

    private func deviceCrashes(in range: Range<Date>, store: EntityStore) async throws -> [SeriesPoint] {
        try await store.query(CrashEntry.recordType).series(
            metric: .sum,
            group: "device_id",
            range: range
        )
    }

    private func deviceSessions(in range: Range<Date>, store: EntityStore) async throws -> [SeriesPoint] {
        try await store.query(SessionEntry.recordType).series(
            metric: .sum,
            group: "device_id",
            range: range
        )
    }

    private func deviceModels(for sessions: [SeriesPoint], store: EntityStore) async throws -> [String: String] {
        let devices = try await store.fetch(
            entity: DeviceEntry.recordType,
            uuids: Array(Set(sessions.filter(\.hasGroup).map(\.group)))
        )
        return devices.reduce(into: [:]) { models, record in
            if let device: String = record["device_id"], let model: String = record["model"] {
                models[device] = model
            }
        }
    }
}
