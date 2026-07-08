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
            devices: IncidentBreakdown.segments(from: try await models),
            osVersions: IncidentBreakdown.segments(from: try await versions)
        )
    }

    private func deviceModels(in database: DatabaseReader) async throws -> [String] {
        guard deviceIDs.count > 0 else { return [] }

        let query = RecordQuery(
            recordType: Device.self,
            filters: [RecordQuery.Filter(field: "device_id", op: .in, value: .strings(deviceIDs.map(\.uuidString)))]
        )
        let records: [Record] = try await database.readAll(matching: query, fields: ["device_id", "model"])
        return records.compactMap { (record: Record) -> String? in record["model"] }
    }

    private func osVersions(in database: DatabaseReader) async throws -> [String] {
        guard sessionIDs.count > 0 else { return [] }

        let query = RecordQuery(
            recordType: Session.self,
            filters: [RecordQuery.Filter(field: "session_id", op: .in, value: .strings(sessionIDs.map(\.uuidString)))]
        )
        let records: [Record] = try await database.readAll(matching: query, fields: ["session_id", "os_version"])
        return records.compactMap { (record: Record) -> String? in record["os_version"] }
    }
}
