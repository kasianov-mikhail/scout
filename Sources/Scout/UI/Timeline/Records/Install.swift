//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

struct InstallRail: Identifiable {
    let install: Install
    let launches: [LaunchRail]

    var id: CKRecord.ID { install.id }
}

struct Install: Identifiable, Hashable {
    let date: Date?
    let id: CKRecord.ID
    let installID: UUID?
    let deviceID: UUID?
}

extension Install: RecordDecodable {
    static let desiredKeys = [
        "date",
        "install_id",
        "device_id",
    ]

    init(record: CKRecord) throws {
        date = record["date"]
        id = record.recordID
        installID = record["install_id"].flatMap(UUID.init)
        deviceID = record["device_id"].flatMap(UUID.init)
    }
}

extension Install {
    static func sample(at date: Date) -> Install {
        Install(
            date: date,
            id: CKRecord.ID(recordName: UUID().uuidString),
            installID: nil,
            deviceID: nil
        )
    }
}
