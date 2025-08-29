//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension SessionObject {
    static func trigger(in context: NSManagedObjectContext) throws {
        let entity = NSEntityDescription.entity(forEntityName: "SessionObject", in: context)!
        let session = SessionObject(entity: entity, insertInto: context)
        session.date = Date()
        try context.save()
    }

    static func complete(in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<SessionObject>(entityName: "SessionObject")
        request.sortDescriptors = [NSSortDescriptor(key: "datePrimitive", ascending: false)]
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
        try context.save()
    }
}

extension SessionObject {
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
}
