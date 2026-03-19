//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(IDObject)
class IDObject: DateObject {

    @NSManaged var launchID: UUID?
    @NSManaged var sessionID: UUID?
    @NSManaged var userID: UUID?

    @nonobjc class func fetchRequest() -> NSFetchRequest<IDObject> {
        NSFetchRequest<IDObject>(entityName: "IDObject")
    }

    override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: #keyPath(IDObject.sessionID))
        setPrimitiveValue(IDs.user, forKey: #keyPath(IDObject.userID))
        setPrimitiveValue(IDs.launch, forKey: #keyPath(IDObject.launchID))
    }

    var metadata: [String: Any] {
        var fields: [String: Any] = [:]
        fields["hour"] = hour
        fields["day"] = day
        fields["week"] = week
        fields["month"] = month
        fields["launch_id"] = launchID?.uuidString
        fields["user_id"] = userID?.uuidString
        fields["version"] = 1
        return fields
    }
}
