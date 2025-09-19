//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

class MetricsProvider: ObservableObject {
    @Published var telemetry: Telemetry.Visible
    @Published var data: [String]?

    init(telemetry: Telemetry.Visible) {
        self.telemetry = telemetry
    }
}

extension MetricsProvider: Provider {
    func fetch(in database: DatabaseController) async {
        let range = Calendar(identifier: .iso8601).queryRange

        do {
            let records = try await database.allRecords(
                matching: query(from: range),
                desiredKeys: nil
            )

            let rawPoints = try records.map(Matrix<GridCell<Int>>.init)
                .mergeDuplicates()
                .flatMap(ChartPoint.fromIntMatrix)

            let rawData = RawPointData(range: range, points: rawPoints)

            print(rawData)
            data = ["Crash", "Launch", "Active", "Background", "Memory", "CPU", "Disk", "Network"]
//            data = Dictionary(uniqueKeysWithValues: periods.map { period in
//                (period, rawData.group(by: period.pointComponent))
//            })

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
            recordType: telemetry.matrixValue.recordName,
            predicate: predicate
        )

        return query
    }
}
