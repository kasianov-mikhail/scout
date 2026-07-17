//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import ScoutCore

extension InstallEntry {
    @discardableResult static func stub(
        date: Date,
        synced: Bool = false,
        device: DeviceEntry? = nil,
        in context: NSManagedObjectContext
    ) -> InstallEntry {
        let install = context.insert(InstallEntry.self)

        install.installID = Identity.stub.install
        install.date = date
        install.setSynced(synced, in: context)
        install.device = device

        return install
    }
}
