//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension NSManagedObjectContext {
    // Inserts a new managed object of the given type, resolving its entity by
    // the class's simple name (which matches the Core Data entity name here).
    func insert<T: NSManagedObject>(_ type: T.Type) -> T {
        let entity = NSEntityDescription.entity(forEntityName: String(describing: type), in: self)!
        return NSManagedObject(entity: entity, insertInto: self) as! T
    }
}
