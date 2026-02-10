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
            "User_Login": Event.Level.info,
            "Page_View": .info,
            "Button_Click": .debug,
            "Purchase": .notice,
            "Item_Added_To_Cart": .info,
            "Item_Removed_From_Cart": .info,
            "Search_Performed": .debug,
            "Profile_Updated": .notice,
            "Settings_Changed": .notice,
            "Logout": .info,
            "App_Launch": .info,
            "App_Close": .info,
            "Notification_Received": .info,
            "Error_Occurred": .error,
            "System_Crash": .critical,
            "Low_Disk_Space": .warning,
            "High_Memory_Usage": .warning,
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
