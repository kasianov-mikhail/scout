//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@testable import Scout

extension NSManagedObjectContext {
    /// A private-queue sibling sharing this context's coordinator, standing in for
    /// the background contexts `performBackgroundTask` hands every record write.
    func backgroundSibling() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        context.mergePolicy = NSMergePolicy.scout
        return context
    }
}
