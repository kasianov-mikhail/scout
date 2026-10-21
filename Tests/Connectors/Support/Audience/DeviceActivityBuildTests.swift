//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import ConnectorSupport
import Foundation
import Testing

@testable import Scout

@Suite("Device counts from records")
struct DeviceActivityBuildTests {
    private let start = Date(timeIntervalSince1970: 1_750_000_000)

    @Test("Counts each device once per range it has a session in")
    func distinctPerRange() {
        let sessions = [
            session(device: "a", at: start),
            session(device: "a", at: start.addingTimeInterval(60)),
            session(device: "b", at: start.addingTimeInterval(120)),
            session(device: "a", at: start.addingTimeInterval(3600)),
        ]

        let counts = sessions.deviceCounts(
            in: [
                start..<start.addingTimeInterval(600),
                start.addingTimeInterval(600)..<start.addingTimeInterval(7200),
                start.addingTimeInterval(7200)..<start.addingTimeInterval(9000),
            ]
        )

        #expect(counts == [2, 1, 0])
    }

    private func session(device: String, at date: Date) -> Record {
        var record = Record(recordType: SessionEntry.recordType, recordID: UUID().uuidString)
        record["device_id"] = device
        record["start_date"] = date
        return record
    }
}
