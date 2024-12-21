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
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
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

        if let string = UserDefaults.standard.string(forKey: userKey),
            let userID = UUID(uuidString: string)
        {
            return userID
        }

        let userID = UUID()
        UserDefaults.standard.set(userID.uuidString, forKey: userKey)
        return userID
    }()
}

// MARK: - Default Values

extension Session {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: #keyPath(Session.sessionID))
        setPrimitiveValue(IDs.user, forKey: #keyPath(Session.userID))
        setPrimitiveValue(IDs.launch, forKey: #keyPath(Session.launchID))
    }
}

extension EventModel {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(IDs.session, forKey: #keyPath(EventModel.sessionID))
        setPrimitiveValue(IDs.user, forKey: #keyPath(EventModel.userID))
        setPrimitiveValue(IDs.launch, forKey: #keyPath(EventModel.launchID))
    }
}
