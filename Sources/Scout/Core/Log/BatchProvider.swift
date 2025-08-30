//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

final class BatchProvider<T: NSManagedObject> {
    let context: NSManagedObjectContext
    let keyPaths: [PartialKeyPath<T>]

    init(context: NSManagedObjectContext, keyPaths: [PartialKeyPath<T>]) {
        self.context = context
        self.keyPaths = keyPaths
    }

    func batch() throws -> [T]? {
        let entityName = String(describing: T.self)

        let seedRequest = NSFetchRequest<T>(entityName: entityName)
        seedRequest.predicate = NSPredicate(format: "isSynced == false")
        seedRequest.fetchLimit = 1

        guard let seed = try context.fetch(seedRequest).first else {
            return nil
        }

        var predicates: [NSPredicate] = [NSPredicate(format: "isSynced == false")]
        for keyPath in keyPaths {
            if let key = keyPath._kvcKeyPathString, let value = seed.value(forKey: key) as? NSObject {
                predicates.append(NSPredicate(format: "%K == %@", key, value))
            }
        }

        let batchRequest = NSFetchRequest<T>(entityName: entityName)
        batchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        return try context.fetch(batchRequest)
    }
}
