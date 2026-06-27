//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

extension DeviceObject {
    @discardableResult static func stub(
        date: Date,
        synced: Bool = false,
        in context: NSManagedObjectContext
    ) -> DeviceObject {
        let device = context.insert(DeviceObject.self)

        device.date = date
        device.setSynced(synced, in: context)

        return device
    }
}
