//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation

/// An enumeration that encapsulates various identifiers used within the Scout application.
/// This enumeration is intended to provide a centralized location for managing and accessing
/// different types of IDs, ensuring consistency and reducing the risk of hardcoding values
/// throughout the codebase.
///
enum IDs {

    /// A static computed property that returns an optional UUID representing the session ID.
    static var session: UUID? {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<SessionObject> = SessionObject.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "datePrimitive", ascending: false)]
        request.predicate = NSPredicate(format: "launchID == %@", launch as CVarArg)
        request.fetchLimit = 1
        let session = try? context.fetch(request).first
        return session?.sessionID
    }

    /// A static constant that generates a new universally unique identifier (UUID) for a launch event.
    static let launch = UUID()

    /// A static constant representing a unique identifier for a user.
    /// The UUID is generated lazily when first accessed.
    ///
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

// MARK: - UUID

extension UserDefaults {

    /// Sets a UUID value in the user defaults for the specified key.
    fileprivate func set(_ value: UUID, forKey key: String) {
        set(value.uuidString, forKey: key)
    }

    /// Retrieves a UUID value from the user defaults for the specified key.
    fileprivate func uuid(forKey key: String) -> UUID? {
        guard let string = string(forKey: key) else { return nil }
        return UUID(uuidString: string)
    }
}

// MARK: - Default Values

extension SessionObject {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: #keyPath(SessionObject.sessionID))
        setPrimitiveValue(IDs.user, forKey: #keyPath(SessionObject.userID))
        setPrimitiveValue(IDs.launch, forKey: #keyPath(SessionObject.launchID))
    }
}

extension EventObject {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: #keyPath(EventObject.eventID))
        setPrimitiveValue(IDs.session, forKey: #keyPath(EventObject.sessionID))
        setPrimitiveValue(IDs.user, forKey: #keyPath(EventObject.userID))
        setPrimitiveValue(IDs.launch, forKey: #keyPath(EventObject.launchID))
    }
}

extension UserActivity {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: #keyPath(UserActivity.userActivityID))
        setPrimitiveValue(IDs.session, forKey: #keyPath(UserActivity.sessionID))
        setPrimitiveValue(IDs.user, forKey: #keyPath(UserActivity.userID))
        setPrimitiveValue(IDs.launch, forKey: #keyPath(UserActivity.launchID))
    }
}
