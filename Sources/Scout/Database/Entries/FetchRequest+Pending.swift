//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc extension NSFetchRequest {
    convenience init(entityName: String, pendingBackendID: String) {
        self.init(entityName: entityName)

        predicate = NSPredicate(
            format: """
                SUBQUERY(deliveries, $d, \
                $d.backendID == %@ AND $d.isPending == YES AND $d.attempts < %d\
                ).@count > 0
                """,
            pendingBackendID,
            DeliveryEntry.maxAttempts
        )
        relationshipKeyPathsForPrefetching = ["deliveries"]
        fetchLimit = DeliveryEntry.pageSize
    }
}
