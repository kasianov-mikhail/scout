//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension NSManagedObjectContext {
    // Resolves the entity by the class's simple name, which matches the
    // Core Data entity name for every managed object in the model.
    func insert<T: NSManagedObject>(_ type: T.Type) -> T {
        let entity = NSEntityDescription.entity(forEntityName: String(describing: type), in: self)!
        return T(entity: entity, insertInto: self)
    }
}
