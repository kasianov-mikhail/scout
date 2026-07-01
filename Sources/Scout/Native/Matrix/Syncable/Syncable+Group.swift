//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension Syncable {
    static func pending(in context: NSManagedObjectContext, for backendID: String) throws -> [Self] {
        let request = NSFetchRequest<Self>(entityName: String(describing: Self.self))
        request.predicate = NSPredicate(.raw, to: backendID)
        return try context.fetch(request)
    }

    static func group(in context: NSManagedObjectContext, for backendID: String) throws -> [Self]? {
        let entityName = String(describing: Self.self)
        let seedPredicate = NSPredicate(.matrix, to: backendID)

        let seedRequest = NSFetchRequest<Self>(entityName: entityName)
        seedRequest.predicate = seedPredicate
        seedRequest.fetchLimit = 1

        guard let seed = try context.fetch(seedRequest).first else {
            return nil
        }

        var predicates = [seedPredicate]

        for key in batchKeys.compactMap(\._kvcKeyPathString) {
            if let value = seed.value(forKey: key) as? NSObject {
                predicates.append(NSPredicate(format: "%K == %@", key, value))
            } else {
                predicates.append(NSPredicate(format: "%K == nil", key))
            }
        }

        let batchRequest = NSFetchRequest<Self>(entityName: entityName)
        batchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        return try context.fetch(batchRequest)
    }
}

extension NSPredicate {
    fileprivate convenience init(_ progress: SyncDelivery.Progress, to backendID: String) {
        self.init(
            format: "SUBQUERY(deliveries, $d, $d.backendID == %@ AND $d.progressPrimitive IN %@ AND $d.attempts < %d).@count > 0",
            backendID,
            progress.owingStates,
            SyncDelivery.maxAttempts
        )
    }
}

extension SyncDelivery.Progress {
    fileprivate var owingStates: [Int16] {
        (0...Self.all.rawValue)
            .filter { Self(rawValue: $0).contains(self) }
            .map { Int16($0) }
    }
}
