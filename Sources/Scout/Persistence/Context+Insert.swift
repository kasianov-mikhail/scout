//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension NSManagedObjectContext {
    func insert<T: NSManagedObject>(_ type: T.Type) -> T {
        let entity = NSEntityDescription.entity(forEntityName: String(describing: type), in: self)!
        return T(entity: entity, insertInto: self)
    }
}
