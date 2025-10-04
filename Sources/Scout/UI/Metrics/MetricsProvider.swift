//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Charts
import SwiftUI

class MetricsProvider<T: MatrixValue & Plottable>: ObservableObject, Provider {
    @Published var telemetry: Telemetry.Scope
    @Published var keys: [String]?
    @Published var data: ChartData<Period, T>?

    init(telemetry: Telemetry.Scope) {
        self.telemetry = telemetry
    }

    func fetch(in database: DatabaseController) async {
        let range = Calendar(identifier: .iso8601).defaultRange

        do {
            let records = try await database.allRecords(
                matching: query(from: range),
                desiredKeys: nil
            )

            let matrices = try records.map(Matrix<GridCell<T>>.init).mergeDuplicates()
            let rawPoints = matrices.flatMap(ChartPoint<T>.fromGridMatrix)
            let rawData = RawPointData(range: range, points: rawPoints)

            keys = Dictionary(grouping: matrices, by: \.name).map(\.key)

            data = Dictionary(
                uniqueKeysWithValues: Period.all.map { period in
                    (period, rawData.group(by: period.pointComponent))
                }
            )

        } catch {
            print(error.localizedDescription)

            keys = nil
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
