//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

/// A class that represents a statistical data fetcher and manager.
@MainActor class StatProvider: ObservableObject {

    /// The name of the event for which the statistics are being fetched.
    let eventName: String

    /// The periods for which the statistics are fetched.
    let periods: [Period]

    /// The statistical data fetched from the cloud, published to notify observers of changes.
    @Published var data: ChartData<Period>?

    /// Initializes a new instance of `StatProvider` with the specified event name and periods.
    init(eventName: String, periods: [Period]) {
        self.eventName = eventName
        self.periods = periods
    }

    /// Fetches data if needed from the provided database.
    ///
    /// This asynchronous function checks if the data needs to be fetched and performs the fetch operation
    /// using the given `DatabaseController` instance.
    ///
    /// - Parameter database: The `DatabaseController` instance used to fetch the data.
    /// - Returns: An asynchronous operation that fetches the data if needed.
    ///
    func fetchIfNeeded(in database: DatabaseController) async {
        if data == nil {
            await fetch(in: database)
        }
    }
}

// MARK: - Fetching Data

extension StatProvider {

    /// Fetches data from the specified database asynchronously.
    ///
    /// - Parameter database: The `DatabaseController` instance from which to fetch data.
    ///
    private func fetch(in database: DatabaseController) async {
        let range = Calendar(identifier: .iso8601).queryRange

        do {
            let records = try await database.allRecords(
                matching: query(from: range.lowerBound),
                desiredKeys: nil
            )

            let rawPoints = try records.map(Matrix<Cell<Int>>.init)
                .mergeDuplicates()
                .flatMap(ChartPoint.fromIntMatrix)

            let rawData = RawPointData(range: range, points: rawPoints)

            data = Dictionary(uniqueKeysWithValues: periods.map { period in
                (period, rawData.group(by: period.pointComponent))
            })

        } catch {
            print(error.localizedDescription)
            data = nil
        }
    }

    private func query(from date: Date) async throws -> CKQuery {
        let predicate = NSPredicate(
            format: "date >= %@ AND name == %@",
            date as NSDate,
            eventName
        )

        let query = CKQuery(
            recordType: "DateIntMatrix",
            predicate: predicate
        )

        return query
    }
}
