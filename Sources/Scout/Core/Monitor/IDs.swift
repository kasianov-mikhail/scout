//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation

enum IDs {
    static var session: UUID? {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<SessionObject> = SessionObject.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "datePrimitive", ascending: false)]
        request.predicate = NSPredicate(format: "launchID == %@", launch as CVarArg)
        request.fetchLimit = 1
        let session = try? context.fetch(request).first
        return session?.sessionID
    }

    static let launch = UUID()

    static let user: UUID = {
        let userKey = "scout_log_user_id"

        if let userID = UserDefaults.standard.uuid(forKey: userKey) {
            return userID
        }

        let userID = UUID()
        UserDefaults.standard.set(userID, forKey: userKey)
        return userID
    }()
}

extension UserDefaults {
    fileprivate func set(_ value: UUID, forKey key: String) {
        set(value.uuidString, forKey: key)
    }

    fileprivate func uuid(forKey key: String) -> UUID? {
        guard let string = string(forKey: key) else { return nil }
        return UUID(uuidString: string)
    }
}

@objc(IDObject)
class IDObject: DateObject {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: #keyPath(IDObject.sessionID))
        setPrimitiveValue(IDs.user, forKey: #keyPath(IDObject.userID))
        setPrimitiveValue(IDs.launch, forKey: #keyPath(IDObject.launchID))
    }
}
