//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Charts
import CloudKit
import SwiftUI

class MetricsProvider<T: ChartNumeric>: ObservableObject, Provider {
    @Published var data: [GridMatrix<T>]?

    private let telemetry: Telemetry.Export

    init(telemetry: Telemetry.Export) {
        self.telemetry = telemetry
    }

    func fetch(in database: DatabaseController) async {
        let dateRange = Calendar(identifier: .iso8601).defaultRange

        do {
            let records = try await database.allRecords(
                matching: query(for: dateRange),
                desiredKeys: nil
            )

            data = try records.map(GridMatrix.init).mergeDuplicates()

        } catch {
            print("Failed to fetch metrics: ", error)
            data = nil
        }
    }

    private func query(for dateRange: ClosedRange<Date>) -> CKQuery {
        let predicate = NSPredicate(
            format: "date >= %@ AND date < %@ AND category == %@",
            dateRange.lowerBound as NSDate,
            dateRange.upperBound as NSDate,
            telemetry.rawValue
        )

        return CKQuery(
            recordType: T.recordName,
            predicate: predicate
        )
    }
}
