//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(ScoutCachedSpan)
final class CachedSpan: NSManagedObject {
    @NSManaged var fingerprint: String
    @NSManaged var lowerDate: Date
    @NSManaged var upperDate: Date

    convenience init(fingerprint: String, lowerDate: Date, upperDate: Date, context: NSManagedObjectContext) {
        self.init(context: context)
        self.fingerprint = fingerprint
        self.lowerDate = lowerDate
        self.upperDate = upperDate
    }

    static func request(fingerprint: String) -> NSFetchRequest<CachedSpan> {
        let request = NSFetchRequest<CachedSpan>(entityName: "CachedSpan")
        request.predicate = predicate(fingerprint: fingerprint)
        request.fetchLimit = 1
        return request
    }

    static func predicate(fingerprint: String) -> NSPredicate {
        NSPredicate(format: "fingerprint == %@", fingerprint)
    }
}
