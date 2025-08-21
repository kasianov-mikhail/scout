//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

/// A typealias for a matrix of period cells containing integer values.
/// This is used to represent a grid of data points for a specific period.
///
typealias PeriodMatrix = Matrix<PeriodCell<Int>>

/// A provider class responsible for managing and fetching active user data.
/// This class is an `ObservableObject` and is designed to be used in SwiftUI views.
///
@MainActor class ActivityProvider: ObservableObject {

    /// Published property containing the chart data for active users.
    @Published var data: ChartData<ActivityPeriod>?

    /// Fetches data if it has not already been loaded.
    /// - Parameter database: The `DatabaseController` instance used to fetch data.
    ///
    func fetchIfNeeded(in database: DatabaseController) async {
        if data == nil {
            await fetch(in: database)
        }
    }
}

// MARK: - Fetching Data

/// An extension of `ActivityProvider` that provides methods to fetch data from the database.
///
/// This extension includes methods to fetch active user data from the database and convert it
/// into a format suitable for charting. It also includes a method to create a query for fetching
/// the data based on a specified date range. The fetched data is stored in the `data` property
/// of the `ActivityProvider` class.
///
extension ActivityProvider {

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
