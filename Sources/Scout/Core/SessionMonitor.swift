//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

struct SessionMonitor {

    /// Registers a new session.
    ///
    /// This method is responsible for initializing and registering a new session
    /// within the application. It sets up necessary configurations and ensures
    /// that the session is properly tracked and managed.
    ///
    static func trigger() async throws {
        try await persistentContainer.performBackgroundTask { context in
            let session = Session(context: context)
            session.startDate = Date()
            session.uuid = UUID()
            try context.save()
        }
    }

    /// An error that occurs when completing a session.
    /// - sessionNotFound: The session to be completed was not found.
    ///
    enum CompleteError: LocalizedError {
        case sessionNotFound

        var errorDescription: String? {
            switch self {
            case .sessionNotFound:
                return "Session not found"
            }
        }
    }

    /// Completes the current session by performing necessary cleanup and finalization tasks.
    /// This method should be called when the session is ready to be terminated.
    ///
    static func complete() async throws {
        try await persistentContainer.performBackgroundTask { context in
            let request = NSFetchRequest<Session>(entityName: "Session")
            request.predicate = NSPredicate(format: "endDate == nil")
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
            request.fetchLimit = 1

            guard let session = try context.fetch(request).first else {
                throw CompleteError.sessionNotFound
            }

            session.endDate = Date()
            try context.save()
        }
    }
}
