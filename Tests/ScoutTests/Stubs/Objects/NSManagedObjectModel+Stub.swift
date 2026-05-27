//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension NSManagedObjectModel {
    static func stub() -> NSManagedObjectModel {
        // Build a minimal model with a single entity so the container is valid.
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "Dummy"
        entity.managedObjectClassName = "NSManagedObject"

        let attribute = NSAttributeDescription()
        attribute.name = "id"
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = false

        entity.properties = [attribute]
        model.entities = [entity]

        return model
    }
}
