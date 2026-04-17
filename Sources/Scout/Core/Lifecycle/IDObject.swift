//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

/// `DateObject` that carries the three app-context IDs
/// (`deviceID`, `installID`, `launchID`) populated from global `IDs` on insert.
///
/// Used to correlate records back to the specific device/install/launch
/// they were produced in.
///
@objc(IDObject)
class IDObject: DateObject {
    @NSManaged var deviceID: UUID?
    @NSManaged var installID: UUID?
    @NSManaged var launchID: UUID?

    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(IDs.device, forKey: #keyPath(IDObject.deviceID))
        setPrimitiveValue(IDs.install, forKey: #keyPath(IDObject.installID))
        setPrimitiveValue(IDs.launch, forKey: #keyPath(IDObject.launchID))
    }

    var metadata: [String: Any] {
        var fields: [String: Any] = [:]
        fields["hour"] = hour
        fields["day"] = day
        fields["week"] = week
        fields["month"] = month
        fields["device_id"] = deviceID?.uuidString
        fields["install_id"] = installID?.uuidString
        fields["launch_id"] = launchID?.uuidString
        fields["version"] = 1
        return fields
    }
}
