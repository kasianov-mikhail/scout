//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(SessionEntry)
final class SessionEntry: SyncableEntry, HasLaunch {
    static let recordType = "Session"

    @NSManaged var appVersion: String?
    @NSManaged var buildNumber: String?
    @NSManaged var endDate: Date?
    @NSManaged var osVersion: String?
    @NSManaged var locale: String?
    @NSManaged var channel: String?
    @NSManaged var sessionID: UUID
    @NSManaged var launch: LaunchEntry?

    @NSManaged var crashes: Set<CrashEntry>
    @NSManaged var hangs: Set<HangEntry>
    @NSManaged var events: Set<EventEntry>
    @NSManaged var metrics: Set<MetricsEntry>
    @NSManaged var activities: Set<ActivityEntry>

    override var references: Set<DateEntry> {
        Set(Array(crashes) + Array(hangs) + Array(events) + Array(metrics) + Array(activities))
    }
}

extension SessionEntry: RecordEncodable {
    var record: Record {
        var record = Record(recordType: Self.recordType, recordID: sessionID.uuidString)

        record["start_date"] = date
        record["end_date"] = endDate
        record["session_id"] = sessionID.uuidString
        record["launch_id"] = launchID?.uuidString
        record["install_id"] = installID?.uuidString
        record["device_id"] = deviceID?.uuidString
        record["app_version"] = appVersion
        record["build_number"] = buildNumber
        record["os_version"] = osVersion
        record["locale"] = locale
        record["channel"] = channel

        record.setValues(metadata)

        return record
    }
}
