//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension VersionObject: PartialMonitor {
    static func trigger(in context: NSManagedObjectContext) throws {
        let entity = NSEntityDescription.entity(forEntityName: "VersionObject", in: context)!
        let version = VersionObject(entity: entity, insertInto: context)
        version.date = Date()
        version.appVersion = Bundle.main.marketingVersion
        version.buildNumber = Bundle.main.buildNumber
        try context.save()
    }
}

extension Bundle {
    var marketingVersion: String? {
        infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildNumber: String? {
        infoDictionary?["CFBundleVersion"] as? String
    }
}
