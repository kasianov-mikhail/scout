//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData

@objc(ScoutCachedRecord)
final class CachedRecord: NSManagedObject {
    @NSManaged var fingerprint: String
    @NSManaged var date: Date
    @NSManaged var payload: Data
    @NSManaged var size: Int64

    convenience init(fingerprint: String, date: Date, payload: Data, context: NSManagedObjectContext) {
        self.init(context: context)
        self.fingerprint = fingerprint
        self.date = date
        self.payload = payload
        self.size = Int64(payload.count)
    }

    static func request(fingerprint: String) -> NSFetchRequest<CachedRecord> {
        let request = NSFetchRequest<CachedRecord>(entityName: "CachedRecord")
        request.predicate = predicate(fingerprint: fingerprint)
        request.fetchLimit = 1
        return request
    }

    static func request(fingerprint: String, in range: Range<Date>) -> NSFetchRequest<CachedRecord> {
        let request = NSFetchRequest<CachedRecord>(entityName: "CachedRecord")
        request.predicate = predicate(fingerprint: fingerprint, in: range)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return request
    }

    static func predicate(fingerprint: String) -> NSPredicate {
        NSPredicate(format: "fingerprint == %@", fingerprint)
    }

    static func predicate(fingerprint: String, in range: Range<Date>) -> NSPredicate {
        NSPredicate(format: "fingerprint == %@ AND date >= %@ AND date < %@", fingerprint, range.lowerBound as NSDate, range.upperBound as NSDate)
    }
}
