//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension NSManagedObjectContext {
    func deleteAll(entity: String, predicate: NSPredicate) throws {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetch.predicate = predicate
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        request.resultType = .resultTypeObjectIDs

        let result = try execute(request) as? NSBatchDeleteResult
        let identifiers = result?.result as? [NSManagedObjectID] ?? []
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: identifiers], into: [self])
    }
}
