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

    /// The statistical data fetched from the cloud, published to notify observers of changes.
    @Published var data: ChartData?

    /// Initializes a new instance of `StatProvider` with the specified event name.
    init(eventName: String) {
        self.eventName = eventName
    }

    /// Fetches the statistical data if it has not been fetched yet.
    /// - Parameter container: The CloudKit container from which to fetch the data.
    ///
    func fetchIfNeeded(in database: DatabaseController) async {
        if data == nil {
            await fetch(in: database)
        }
    }

    /// Fetches the statistical data from the CloudKit container.
    /// - Parameter container: The CloudKit container from which to fetch the data.
    ///
    private func fetch(in database: DatabaseController) async {
        let predicate = Self.predicate(for: eventName)
        let query = CKQuery(recordType: "DateIntMatrix", predicate: predicate)

        do {
            let records = try await database.allRecords(
                matching: query,
                desiredKeys: nil
            )

            data = try records.map(Matrix.init)
                .mergeDuplicates()
                .flatMap(ChartPoint.fromIntMatrix)
                .toChartData
        } catch {
            print(error.localizedDescription)
            data = nil
        }
    }
}

// MARK: - Configuring the Request

extension StatProvider {

    /// Creates a predicate for querying the CloudKit database based on the event name.
    /// - Parameter eventName: The name of the event.
    /// - Returns: An `NSPredicate` for querying the CloudKit database.
    ///
    static func predicate(for eventName: String) -> NSPredicate {
        let today = Calendar(identifier: .iso8601).startOfDay(for: Date())
        let yearAgo = today.addingYear(-1).addingWeek(-1)
        let predicate = NSPredicate(
            format: "date >= %@ AND name == %@",
            yearAgo.addingWeek(-1) as NSDate,
            eventName
        )
        return predicate
    }
}

// MARK: - Data Processing

extension [ChartPoint] {

    /// Converts the current `Stat` instance into `ChartData` by grouping the data
    /// according to all cases of `StatPeriod`.
    ///
    /// - Returns: A dictionary where the keys are `StatPeriod` cases and the values
    ///   are the grouped data for each period.
    ///
    var toChartData: ChartData {
        StatPeriod.allCases.reduce(into: [:]) { dict, period in
            dict[period] = period.group(self)
        }
    }
}
