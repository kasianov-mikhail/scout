//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Scout
import SwiftUI

private let membershipLimit = 250

@MainActor
final class IncidentBreakdownProvider: ObservableObject, RecordProvider {
    @Published var result: ProviderResult<IncidentBreakdown>?

    private let deviceIDs: [UUID]
    private let sessionIDs: [UUID]

    init(_ result: ProviderResult<Output>? = nil, deviceIDs: [UUID], sessionIDs: [UUID]) {
        self.deviceIDs = deviceIDs
        self.sessionIDs = sessionIDs
        self.result = result
    }

    func fetch(in database: RecordReader) async throws -> IncidentBreakdown {
        async let models = deviceModels(in: database)
        async let versions = osVersions(in: database)

        return try await IncidentBreakdown(
            devices: IncidentBreakdown.segments(from: Array(models.values)),
            osVersions: IncidentBreakdown.segments(from: Array(versions.values)),
            modelsByDevice: models,
            versionsBySession: versions
        )
    }

    private func deviceModels(in database: RecordReader) async throws -> [UUID: String] {
        let records = try await records(type: Device.self, field: "device_id", ids: deviceIDs, fields: ["device_id", "model"], database: database)
        return dictionary(from: records, key: "device_id", value: "model")
    }

    private func osVersions(in database: RecordReader) async throws -> [UUID: String] {
        let records = try await records(type: Session.self, field: "session_id", ids: sessionIDs, fields: ["session_id", "os_version"], database: database)
        return dictionary(from: records, key: "session_id", value: "os_version")
    }

    private func records(type: any RecordDecodable.Type, field: String, ids: [UUID], fields: [String], database: RecordReader) async throws -> [Record] {
        let values = ids.map(\.uuidString)

        return try await withThrowingTaskGroup(of: [Record].self) { group in
            for start in stride(from: 0, to: values.count, by: membershipLimit) {
                let query = RecordQuery(
                    recordType: type,
                    filters: [
                        RecordQuery.Filter(
                            field: field,
                            op: .in,
                            value: .strings(Array(values[start..<min(start + membershipLimit, values.count)]))
                        )
                    ]
                )
                group.addTask {
                    try await database.readAll(matching: query, fields: fields)
                }
            }

            var records: [Record] = []
            for try await chunk in group {
                records += chunk
            }
            return records
        }
    }

    private func dictionary(from records: [Record], key: String, value: String) -> [UUID: String] {
        let pairs = records.compactMap { (record: Record) -> (UUID, String)? in
            guard let id = record[key].flatMap(UUID.init), let label: String = record[value] else {
                return nil
            }
            return (id, label)
        }
        return Dictionary(pairs, uniquingKeysWith: { first, _ in first })
    }
}
