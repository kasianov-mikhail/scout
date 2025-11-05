//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import CoreData

@objc(EventObject)
final class EventObject: SyncableObject, Syncable {
    static func group(in context: NSManagedObjectContext) throws -> [EventObject]? {
        try batch(in: context, matching: [\.name, \.week])
    }
}
