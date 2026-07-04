//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension NSManagedObjectContext {
    func objects<T: NSManagedObject>(_ type: T.Type, where format: String, _ args: Any..., dateAscending: Bool? = nil, limit: Int? = nil) throws -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = NSPredicate(format: format, argumentArray: args)

        if let dateAscending {
            request.sortDescriptors = [NSSortDescriptor(key: DateObject.datePrimitiveKey, ascending: dateAscending)]
        }
        if let limit {
            request.fetchLimit = limit
        }

        return try fetch(request)
    }
}
