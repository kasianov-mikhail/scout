//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension Session {

    /// Registers a new session.
    ///
    /// This method is responsible for initializing and registering a new session
    /// within the application. It sets up necessary configurations and ensures
    /// that the session is properly tracked and managed.
    ///
    static func trigger(in context: NSManagedObjectContext) throws {
        let entity = NSEntityDescription.entity(forEntityName: "Session", in: context)!
        let session = Session(entity: entity, insertInto: context)
        session.startDate = Date()
        try context.save()
    }
}

// MARK: - Completion

extension Session {

    /// An error that occurs when completing a session.
    /// - sessionNotFound: The session to be completed was not found.
    /// - alreadyCompleted: The session has already been completed.
    ///
    enum CompleteError: LocalizedError, Equatable {
        case sessionNotFound
        case alreadyCompleted(Date)

        var errorDescription: String? {
            switch self {
            case .sessionNotFound:
                return "Session not found"
            case .alreadyCompleted(let date):
                return "Session already completed on \(date)"
            }
        }

        static func == (lhs: CompleteError, rhs: CompleteError) -> Bool {
            switch (lhs, rhs) {
            case (.sessionNotFound, .sessionNotFound):
                return true
            case (.alreadyCompleted, .alreadyCompleted):
                return true
            default:
                return false
            }
        }
    }

    /// Completes the current session by performing necessary cleanup and finalization tasks.
    /// This method should be called when the session is ready to be terminated.
    ///
    static func complete(in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<Session>(entityName: "Session")
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        request.predicate = NSPredicate(format: "launchID == %@", IDs.launch as CVarArg)
        request.fetchLimit = 1

        guard let session = try context.fetch(request).first else {
            throw CompleteError.sessionNotFound
        }

        if let endDate = session.endDate {
            throw CompleteError.alreadyCompleted(endDate)
        }

        let date = Date()
        session.endDate = date
        session.hour = date.startOfHour
        session.week = date.startOfWeek
        try context.save()
    }
}
