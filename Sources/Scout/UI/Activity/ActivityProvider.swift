//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

typealias PeriodMatrix = Matrix<PeriodCell<Int>>

@MainActor
class ActivityProvider: ObservableObject {
    @Published var data: ChartData<ActivityPeriod>?

    func fetchIfNeeded(in database: DatabaseController) async {
        if data == nil {
            await fetch(in: database)
        }
    }

    private func fetch(in database: DatabaseController) async {
        let range = Calendar(identifier: .iso8601).queryRange

        do {
            let records = try await database.allRecords(
                matching: query(from: range.lowerBound, to: range.upperBound),
                desiredKeys: nil
            )

            let matrices = try records.map(PeriodMatrix.init).mergeDuplicates()

            let periodPoints = ActivityPeriod.allCases.map { period in
                let points = matrices.flatMap { matrix in
                    let filteredCells = matrix.cells.filter { cell in
                        cell.period == period
                    }

                    return filteredCells.map { cell in
                        ChartPoint(
                            date: matrix.date.addingDay(cell.day - 1),
                            count: cell.value
                        )
                    }
                }
                return (period, points.sorted())
            }

            data = Dictionary(uniqueKeysWithValues: periodPoints)

        } catch {
            print("Error fetching active user data: \(error)")
            data = nil
        }
    }

    private func query(from: Date, to: Date) async throws -> CKQuery {
        let predicate = NSPredicate(
            format: "date >= %@ AND date < %@ AND name == %@",
            from as NSDate,
            to as NSDate,
            "ActiveUser"
        )

        let query = CKQuery(
            recordType: "PeriodMatrix",
            predicate: predicate
        )

        return query
    }
}
