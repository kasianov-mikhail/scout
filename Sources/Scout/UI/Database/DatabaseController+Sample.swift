//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension DatabaseController {
    static let sampleData = {
        var data: [CKRecord] = []

        let eventLevels: [String: Event.Level] = [
            "UserLogin": .info, "PageView": .info, "ButtonClick": .debug, "Purchase": .notice,
            "ItemAddedToCart": .info, "ItemRemovedFromCart": .info, "SearchPerformed": .debug,
            "ProfileUpdated": .notice, "SettingsChanged": .notice, "Logout": .info,
            "AppLaunch": .info, "AppClose": .info, "NotificationReceived": .info,
            "ErrorOccurred": .error, "SystemCrash": .critical, "LowDiskSpace": .warning,
            "HighMemoryUsage": .warning, "SlowNetwork": .error,
        ]
        let eventParameters: [String: String] = [
            "Browser": "Safari",
            "Platform": "iOS",
            "AppBuild": "1001",
            "Country": "US",
            "City": "San Francisco",
            "Carrier": "AT&T",
            "BatteryLevel": "85%",
            "Orientation": "Portrait",
            "ConnectionType": "4G",
        ]
        let events: [CKRecord] = eventLevels.enumerated().map { index, event in
            let record = CKRecord(recordType: "Event", recordID: CKRecord.ID())
            record["name"] = event.key
            record["userID"] = UUID().uuidString
            record["sessionID"] = UUID().uuidString
            record["date"] = Date().addingTimeInterval(TimeInterval(-index * 80))
            record["level"] = event.value.rawValue
            record["param_count"] = Int64(eventParameters.count)
            record["params"] = try! JSONEncoder().encode(eventParameters)
            return record
        }
        data.append(contentsOf: events)

        let date = Date().startOfWeek
        let matrices = (0..<10).map { index in
            let record = CKRecord(
                recordType: "DateIntMatrix",
                recordID: CKRecord.ID(recordName: "\(index)")
            )
            record["date"] = date.addingWeek(-index)
            record["name"] = "Event"
            for i in 0..<7 {
                for j in 0..<24 {
                    record["cell_\(i)_\(j)"] = Int.random(in: 0...100)
                }
            }
            return record
        }
        data.append(contentsOf: matrices)

        return data
    }()

    static let sampleDataResults: Results = {
        sampleData.map { ($0.recordID, .success($0)) }
    }()
}
