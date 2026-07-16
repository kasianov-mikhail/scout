//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import SwiftUI

@MainActor
final class IncidentBreakdownProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<IncidentBreakdown>?

    private let deviceIDs: [UUID]
    private let sessionIDs: [UUID]

    init(deviceIDs: [UUID], sessionIDs: [UUID]) {
        self.deviceIDs = deviceIDs
        self.sessionIDs = sessionIDs
    }

    func fetch(in database: DatabaseReader) async throws -> IncidentBreakdown {
        async let models = deviceModels(in: database)
        async let versions = osVersions(in: database)

        return IncidentBreakdown(
            devices: IncidentBreakdown.segments(from: Array(try await models.values)),
            osVersions: IncidentBreakdown.segments(from: Array(try await versions.values)),
            modelsByDevice: try await models,
            versionsBySession: try await versions
        )
    }

    private func deviceModels(in database: DatabaseReader) async throws -> [UUID: String] {
        guard deviceIDs.count > 0 else { return [:] }

        let query = RecordQuery(
            recordType: Device.self,
            filters: [RecordQuery.Filter(field: "device_id", op: .in, value: .strings(deviceIDs.map(\.uuidString)))]
        )
        let records: [Record] = try await database.readAll(matching: query, fields: ["device_id", "model"])
        return dictionary(from: records, key: "device_id", value: "model")
    }

    private func osVersions(in database: DatabaseReader) async throws -> [UUID: String] {
        guard sessionIDs.count > 0 else { return [:] }

        let query = RecordQuery(
            recordType: Session.self,
            filters: [RecordQuery.Filter(field: "session_id", op: .in, value: .strings(sessionIDs.map(\.uuidString)))]
        )
        let records: [Record] = try await database.readAll(matching: query, fields: ["session_id", "os_version"])
        return dictionary(from: records, key: "session_id", value: "os_version")
    }

    private func dictionary(from records: [Record], key: String, value: String) -> [UUID: String] {
        let pairs = records.compactMap { (record: Record) -> (UUID, String)? in
            guard let id = record[key].flatMap(UUID.init), let label: String = record[value] else { return nil }
            return (id, label)
        }
        return Dictionary(pairs, uniquingKeysWith: { first, _ in first })
    }
}
