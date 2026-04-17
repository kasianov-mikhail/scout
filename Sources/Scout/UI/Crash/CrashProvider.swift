//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

@MainActor
class CrashProvider: PaginatingProvider<Crash> {
    func fetch(in database: AppDatabase) async {
        let query = CKQuery(recordType: CrashObject.recordType, predicate: Self.predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        await fetch(matching: query, fields: Crash.desiredKeys, in: database)
    }

    override func handleFetchError(_ error: Error) {
        self.items = []
    }

    override func handlePaginationError(_ error: Error) {
        // Keep existing data on pagination failure
    }

    private static var predicate: NSPredicate {
        let dateRange = Calendar.utc.defaultRange

        return NSPredicate(
            format: "date >= %@ AND date < %@",
            dateRange.lowerBound as NSDate,
            dateRange.upperBound as NSDate
        )
    }
}
