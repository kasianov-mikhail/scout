//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension Event {
    static var sampleRecords: [CKRecord] {
        let eventLevels = [
            "UserLogin": Event.Level.info,
            "PageView": .info,
            "ButtonClick": .debug,
            "Purchase": .notice,
            "ItemAddedToCart": .info,
            "ItemRemovedFromCart": .info,
            "SearchPerformed": .debug,
            "ProfileUpdated": .notice,
            "SettingsChanged": .notice,
            "Logout": .info,
            "AppLaunch": .info,
            "AppClose": .info,
            "NotificationReceived": .info,
            "ErrorOccurred": .error,
            "SystemCrash": .critical,
            "LowDiskSpace": .warning,
            "HighMemoryUsage": .warning,
            "Network": .error,
        ]

        let parameters = [
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

        return eventLevels.enumerated().map { index, event in
            let record = CKRecord(recordType: "Event", recordID: CKRecord.ID())
            record["name"] = event.key
            record["userID"] = UUID().uuidString
            record["sessionID"] = UUID().uuidString
            record["date"] = Date().addingTimeInterval(TimeInterval(-index * 80))
            record["level"] = event.value.rawValue
            record["param_count"] = Int64(parameters.count)
            record["params"] = try! JSONEncoder().encode(parameters)
            return record
        }
    }
}
