//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension LaunchObject: PartialMonitor {
    static func trigger(identity: Identity, in context: NSManagedObjectContext) throws {
        let launch = context.insert(LaunchObject.self)
        launch.launchID = identity.launch
        launch.date = Date()
        launch.install = try context.existing(InstallObject.self, key: "installID", id: identity.install)
        try context.save()
    }
}
