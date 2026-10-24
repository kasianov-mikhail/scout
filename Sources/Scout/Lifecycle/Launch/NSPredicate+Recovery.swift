//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

extension NSPredicate {
    static func unfinished(launchKey: String, outside openLaunchIDs: Set<UUID>) -> NSPredicate {
        let others = openLaunchIDs.map { NSPredicate(format: "%K != %@", launchKey, $0 as CVarArg) }
        return NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "endDate == nil")] + others)
    }
}
