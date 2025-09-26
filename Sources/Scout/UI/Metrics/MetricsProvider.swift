//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

class MetricsProvider: ObservableObject {
    @Published var telemetry: Telemetry.Scope
    @Published var data: [String]?

    init(telemetry: Telemetry.Scope) {
        self.telemetry = telemetry
    }
}

extension MetricsProvider: Provider {
    func fetch(in database: DatabaseController) async {
        let range = Calendar(identifier: .iso8601).defaultRange

        do {
            let records = try await database.allRecords(matching: query(from: range), desiredKeys: nil)
            let rawPoints = try records.map(Matrix<GridCell<Double>>.init).mergeDuplicates()
            let grouped = Dictionary(grouping: rawPoints, by: \.name)

            data = grouped.map(\.key).sorted()

        } catch {
            print(error.localizedDescription)
            data = nil
        }
    }

    private func query(from range: ClosedRange<Date>) -> CKQuery {
        let predicate = NSPredicate(
            format: "date >= %@ AND date < %@ AND category == %@",
            range.lowerBound as NSDate,
            range.upperBound as NSDate,
            telemetry.export.rawValue
        )

        let query = CKQuery(
            recordType: telemetry.valueType.recordName,
            predicate: predicate
        )

        return query
    }
}
