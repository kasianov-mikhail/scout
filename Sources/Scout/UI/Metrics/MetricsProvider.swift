//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

class MetricsProvider: ObservableObject, Provider {
    @Published var telemetry: Telemetry.Scope
    @Published var data: [String]?

    init(telemetry: Telemetry.Scope) {
        self.telemetry = telemetry
    }

    func fetch(in database: DatabaseController) async {
        await fetch(in: database, type: telemetry.valueType)
    }

    func fetch<T: MatrixValue>(in database: DatabaseController, type: T.Type) async {
        let range = Calendar(identifier: .iso8601).defaultRange

        do {
            let records = try await database.allRecords(
                matching: query(from: range),
                desiredKeys: nil
            )

            let matrices = try records.map(Matrix<GridCell<T>>.init).mergeDuplicates()

            data = Dictionary(grouping: matrices, by: \.name).map(\.key)
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

        return CKQuery(
            recordType: telemetry.valueType.recordName,
            predicate: predicate
        )
    }
}
