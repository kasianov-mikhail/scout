//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct TimelineFeed {
    let deviceID: UUID
    let database: DatabaseReader

    func device() async throws -> Device {
        let query = RecordQuery(
            recordType: Device.self,
            filters: [RecordQuery.Filter(field: "device_id", op: .equals, value: .string(deviceID.uuidString))]
        )
        if let record = try await database.read(matching: query, fields: Device.desiredKeys, limit: 1).records.first {
            return try Device(record: record)
        }
        return Device(
            date: nil,
            id: deviceID.uuidString,
            deviceID: deviceID
        )
    }

    func installs() async throws -> [Install] {
        let query = RecordQuery(
            recordType: Install.self,
            filters: [RecordQuery.Filter(field: "device_id", op: .equals, value: .string(deviceID.uuidString))]
        )
        return
            try await database
            .readAll(matching: query, fields: Install.desiredKeys)
            .map(Install.init)
    }

    func launches() async throws -> [Launch] {
        let query = RecordQuery(
            recordType: Launch.self,
            filters: [RecordQuery.Filter(field: "device_id", op: .equals, value: .string(deviceID.uuidString))]
        )
        return
            try await database
            .readAll(matching: query, fields: Launch.desiredKeys)
            .map(Launch.init)
    }
}
