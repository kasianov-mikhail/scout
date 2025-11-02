//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

@MainActor
class ActivityProvider: ObservableObject, Provider {
    @Published var data: [ActivityMatrix]?

    func fetch(in database: DatabaseController) async {
        let range = Calendar.utc.defaultRange

        do {
            let records = try await database.allRecords(
                matching: query(for: range),
                desiredKeys: nil
            )

            data = try records.map(ActivityMatrix.init).mergeDuplicates()

        } catch {
            print("Error fetching active user data: \(error)")
            data = nil
        }
    }

    private func query(for dateRange: ClosedRange<Date>) -> CKQuery {
        let predicate = NSPredicate(
            format: "date >= %@ AND date < %@ AND name == %@",
            dateRange.lowerBound as NSDate,
            dateRange.upperBound as NSDate,
            "ActiveUser"
        )

        let query = CKQuery(
            recordType: "PeriodMatrix",
            predicate: predicate
        )

        return query
    }
}
