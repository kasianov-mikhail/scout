//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

struct CoreDataSyncGroupBuilder {
    /// Creates a seed fetch request for finding unsynced items
    static func createSeedRequest<T: NSManagedObject>(for entityType: T.Type) -> NSFetchRequest<T> {
        let request = NSFetchRequest<T>(entityName: String(describing: entityType))
        request.predicate = NSPredicate(format: "isSynced == false")
        request.fetchLimit = 1
        return request
    }
    
    /// Creates a batch fetch request for unsynced items matching additional criteria
    static func createBatchRequest<T: NSManagedObject>(for entityType: T.Type, additionalPredicate: NSPredicate? = nil) -> NSFetchRequest<T> {
        let request = NSFetchRequest<T>(entityName: String(describing: entityType))
        
        let basePredicate = NSPredicate(format: "isSynced == false")
        
        if let additional = additionalPredicate {
            request.predicate = NSCompoundPredicate(type: .and, subpredicates: [basePredicate, additional])
        } else {
            request.predicate = basePredicate
        }
        
        return request
    }
}