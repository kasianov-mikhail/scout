//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

extension DeviceEntry {
    @discardableResult static func stub(
        date: Date,
        synced: Bool = false,
        in context: NSManagedObjectContext
    ) -> DeviceEntry {
        let device = context.insert(DeviceEntry.self)

        device.deviceID = Identity.stub.device
        device.date = date
        device.setSynced(synced, in: context)

        return device
    }
}
