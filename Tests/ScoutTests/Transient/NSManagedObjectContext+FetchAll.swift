//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension NSManagedObjectContext {
    // Fetches every object of the given type, resolving its entity by the
    // class's simple name (which matches the Core Data entity name here).
    func fetchAll<T: NSManagedObject>(_ type: T.Type) throws -> [T] {
        try fetch(NSFetchRequest<T>(entityName: String(describing: type)))
    }
}
