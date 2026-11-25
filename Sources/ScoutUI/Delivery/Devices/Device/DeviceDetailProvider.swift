//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout
import SwiftUI

@MainActor
final class DeviceDetailProvider: ObservableObject, Provider {
    typealias Output = DeviceDetail

    @Published var result: ProviderResult<DeviceDetail>?
    @Published var range: IncidentRange {
        didSet {
            if range != oldValue {
                result = nil
            }
        }
    }

    let device: DeviceSummary

    init(_ result: ProviderResult<DeviceDetail>? = nil, device: DeviceSummary, range: IncidentRange = .week) {
        self.device = device
        self.range = range
        self.result = result
    }

    func fetch(in database: DatabaseReader) async throws -> DeviceDetail {
        let range = self.range
        let now = Date()
        let bounds = range.range(now: now)
        let deviceID = device.id.uuidString

        async let sessionRecords: [Record] = database.readAll(
            matching: sessionQuery(deviceID: deviceID, bounds: bounds),
            fields: Session.desiredKeys
        )
        async let crashRecords: [Record] = database.readAll(
            matching: incidentQuery(Crash.self, deviceID: deviceID, bounds: bounds),
            fields: Crash.desiredKeys
        )
        async let hangRecords: [Record] = database.readAll(
            matching: incidentQuery(Hang.self, deviceID: deviceID, bounds: bounds),
            fields: Hang.desiredKeys
        )
        async let resourceRecords: [Record] = database.readAll(
            matching: incidentQuery(ResourceException.self, deviceID: deviceID, bounds: bounds),
            fields: ResourceException.desiredKeys
        )
        async let installRecords: [Record] = database.readAll(
            matching: installQuery(deviceID: deviceID),
            fields: Install.desiredKeys
        )

        let installs = try await installRecords.map { try Install(record: $0) }
        async let versionRecords = database.readAll(
            type: Version.self,
            field: "install_id",
            values: installs.compactMap(\.installID).map(\.uuidString),
            fields: Version.desiredKeys
        )

        return try await DeviceDetail(
            summary: device,
            range: range,
            sessions: sessionRecords.map { try Session(record: $0) },
            crashes: crashRecords.map { try Crash(record: $0) },
            hangs: hangRecords.map { try Hang(record: $0) },
            resources: resourceRecords.map { try ResourceException(record: $0) },
            installs: installs,
            versions: versionRecords.map { try Version(record: $0) },
            now: now
        )
    }

    private func sessionQuery(deviceID: String, bounds: Range<Date>) -> RecordQuery {
        RecordQuery(
            recordType: Session.self,
            filters: [deviceFilter(deviceID)] + bounds.dateFilters(on: "start_date"),
            sort: [RecordQuery.Sort(field: "start_date", ascending: false)]
        )
    }

    private func incidentQuery(_ type: any RecordDecodable.Type, deviceID: String, bounds: Range<Date>) -> RecordQuery {
        RecordQuery(
            recordType: type,
            filters: [deviceFilter(deviceID)] + bounds.dateFilters,
            sort: [RecordQuery.Sort(field: "date", ascending: false)]
        )
    }

    private func installQuery(deviceID: String) -> RecordQuery {
        RecordQuery(
            recordType: Install.self,
            filters: [deviceFilter(deviceID)],
            sort: [RecordQuery.Sort(field: "date", ascending: true)]
        )
    }

    private func deviceFilter(_ deviceID: String) -> RecordQuery.Filter {
        RecordQuery.Filter(field: "device_id", op: .equals, value: .string(deviceID))
    }
}
