//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

@MainActor
class CrashProvider: ObservableObject {
    @Published var crashes: [Crash]?
    @Published var cursor: CKQueryOperation.Cursor?

    func fetch(in database: AppDatabase) async {
        do {
            let query = CKQuery(recordType: "Crash", predicate: Self.predicate)
            query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

            let results = try await database.read(
                matching: query,
                fields: Crash.desiredKeys
            )

            self.cursor = results.cursor
            self.crashes = try results.records.map(Crash.init)
        } catch {
            self.crashes = []
        }
    }

    func fetchMore(cursor: CKQueryOperation.Cursor, in database: AppDatabase) async {
        do {
            let results = try await database.readMore(
                from: cursor,
                fields: nil
            )

            self.cursor = results.cursor
            self.crashes?.append(contentsOf: try results.records.map(Crash.init))
        } catch {
            // Keep existing data on pagination failure
        }
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
