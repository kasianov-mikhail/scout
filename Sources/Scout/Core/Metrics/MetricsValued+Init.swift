//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension MetricsValued {
    init(value: Value, in context: NSManagedObjectContext) {
        let entityName = String(describing: Self.self)
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        self.init(entity: entity, insertInto: context)
        self.value = value
    }
}
