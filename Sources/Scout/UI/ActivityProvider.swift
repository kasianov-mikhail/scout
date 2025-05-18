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
    @Published var data: ChartData?

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
        let today = Calendar(identifier: .iso8601).startOfDay(for: Date())
        let yearAgo = today.addingYear(-1).addingWeek(-1)

        do {
            let records = try await database.allRecords(
                matching: query(from: yearAgo),
                desiredKeys: nil
            )

            let rawPoints = try records.map(PeriodMatrix.init)
                .mergeDuplicates()
                .flatMap(ChartPoint.fromPeriodMatrix)

            let rawData = RawPointData(
                from: yearAgo,
                to: today.addingDay(),
                points: rawPoints
            )

            data = rawData.chartData(for: ActivityPeriod.allCases.uniqueComponents)

        } catch {
            print("Error fetching active user data: \(error)")
            data = nil
        }
    }

    private func query(from date: Date) async throws -> CKQuery {
        let predicate = NSPredicate(
            format: "date >= %@ AND name == %@",
            date as NSDate,
            "ActiveUser"
        )

        let query = CKQuery(
            recordType: "PeriodMatrix",
            predicate: predicate
        )

        return query
    }
}

// MARK: - ChartPoint Factory

extension ChartPoint {

    /// Converts a `PeriodMatrix` into an array of `ChartPoint`.
    ///
    /// - Parameter matrix: The matrix to convert.
    /// - Returns: An array of `ChartPoint` objects.
    /// - Throws: An error if the conversion fails.
    ///
    fileprivate static func fromPeriodMatrix(_ matrix: PeriodMatrix) -> [ChartPoint] {
        matrix.cells.map { cell in
            ChartPoint(
                date: matrix.date,
                count: cell.value
            )
        }
    }
}
