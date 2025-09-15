//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension MatrixValue {
    func toObject(in context: NSManagedObjectContext) -> Object {
        let entityName = String(describing: Object.self)
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        var object = NSManagedObject(entity: entity, insertInto: context) as! Object
        object.value = self
        return object
    }
}
