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
        request.predicate = .actionable(for: backendID)
        return try context.fetch(request)
    }

    static func group(in context: NSManagedObjectContext, for backendID: String) throws -> [Self]? {
        let entityName = String(describing: Self.self)
        let actionable = NSPredicate.actionable(for: backendID)

        let seedRequest = NSFetchRequest<Self>(entityName: entityName)
        seedRequest.predicate = actionable
        seedRequest.fetchLimit = 1

        guard let seed = try context.fetch(seedRequest).first else {
            return nil
        }

        var predicates = [actionable]

        for keyPath in batchKeys {
            guard let key = keyPath._kvcKeyPathString else {
                continue
            }
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
    fileprivate static func actionable(for backendID: String) -> NSPredicate {
        NSPredicate(
            format: "SUBQUERY(deliveries, $d, $d.backendID == %@ AND $d.progressPrimitive != 0 AND $d.attempts < %d).@count > 0",
            backendID,
            SyncDelivery.maxAttempts
        )
    }
}
