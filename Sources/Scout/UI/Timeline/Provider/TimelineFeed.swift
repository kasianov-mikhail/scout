//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct TimelineFeed {
    let deviceID: UUID
    let database: AppDatabase

    func device() async throws -> Device {
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

    func installs() async throws -> [Install] {
        let query = CKQuery(
            recordType: InstallObject.recordType,
            predicate: NSPredicate(format: "device_id == %@", deviceID.uuidString)
        )
        return
            try await database
            .readAll(matching: query, fields: nil)
            .map(Install.init)
    }

    func launches() async throws -> [Launch] {
        let query = CKQuery(
            recordType: LaunchObject.recordType,
            predicate: NSPredicate(format: "device_id == %@", deviceID.uuidString)
        )
        return
            try await database
            .readAll(matching: query, fields: nil)
            .map(Launch.init)
    }
}
