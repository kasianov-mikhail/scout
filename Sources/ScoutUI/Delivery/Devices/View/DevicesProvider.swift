//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class DevicesProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<DevicesReport>?

    init(_ result: ProviderResult<Output>? = nil) {
        self.result = result
    }

    func fetch(in database: DatabaseReader) async throws -> DevicesReport {
        async let devices: [Record] = database.readAll(
            matching: RecordQuery(recordType: Device.self),
            fields: ["device_id", "model"]
        )

        async let sessions: [Record] = database.readAll(
            matching: RecordQuery(recordType: Session.self),
            fields: ["device_id", "os_version", "start_date"]
        )

        async let crashes: [Record] = database.readAll(
            matching: RecordQuery(recordType: Crash.self),
            fields: ["device_id"]
        )

        return try await DevicesReport(devices: devices, sessions: sessions, crashes: crashes)
    }
}
