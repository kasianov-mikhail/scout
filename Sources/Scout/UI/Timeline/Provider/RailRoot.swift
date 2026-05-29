//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct RailRoot {
    let deviceID: UUID
    let range: DateInterval?
    let database: AppDatabase

    func load() async throws -> DeviceRail? {
        let device = try await device()
        let installs = try await installs()
        let launches = try await launches()

        return DeviceRail(
            device: device,
            installs: installs,
            launches: launches
        )
    }

    private func device() async throws -> Device {
        let query = CKQuery(
            recordType: DeviceObject.recordType,
            predicate: NSPredicate(format: "device_id == %@", deviceID.uuidString)
        )
        if let record = try await database.readAll(matching: query, fields: nil).first {
            return try Device(record: record)
        }
        return Device(
            date: nil,
            id: CKRecord.ID(recordName: deviceID.uuidString),
            deviceID: deviceID
        )
    }

    private func installs() async throws -> [Install] {
        let query = CKQuery(
            recordType: InstallObject.recordType,
            predicate: range.predicate(field: "device_id", equals: deviceID, dateField: "date")
        )
        return
            try await database
            .readAll(matching: query, fields: nil)
            .map(Install.init)
    }

    private func launches() async throws -> [Launch] {
        let query = CKQuery(
            recordType: LaunchObject.recordType,
            predicate: range.predicate(field: "device_id", equals: deviceID, dateField: "start_date")
        )
        return
            try await database
            .readAll(matching: query, fields: nil)
            .map(Launch.init)
    }
}
