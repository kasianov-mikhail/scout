//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class DeviceIncidentsProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<DeviceIncidents>?

    private let deviceID: UUID

    init(deviceID: UUID) {
        self.deviceID = deviceID
    }

    func fetch(in database: DatabaseReader) async throws -> DeviceIncidents {
        async let crashes: [Crash] = database.readAll(matching: query(for: Crash.self), fields: Crash.desiredKeys)
        async let hangs: [Hang] = database.readAll(matching: query(for: Hang.self), fields: Hang.desiredKeys)

        return try await DeviceIncidents(crashes: crashes.sorted(), hangs: hangs.sorted())
    }

    private func query(for recordType: any RecordDecodable.Type) -> RecordQuery {
        RecordQuery(
            recordType: recordType,
            filters: [RecordQuery.Filter(field: "device_id", op: .equals, value: .string(deviceID.uuidString))],
            sort: [RecordQuery.Sort(field: "date", ascending: false)]
        )
    }
}
