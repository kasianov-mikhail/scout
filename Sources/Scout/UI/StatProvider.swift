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
        let today = Calendar(identifier: .iso8601).startOfDay(for: Date())
        let yearAgo = today.addingYear(-1).addingWeek(-1)

        let predicate = NSPredicate(
            format: "date >= %@ AND name == %@",
            yearAgo as NSDate,
            eventName
        )

        let query = CKQuery(
            recordType: "DateIntMatrix",
            predicate: predicate
        )

        do {
            let records = try await database.allRecords(
                matching: query,
                desiredKeys: nil
            )

            let points = try records.map(Matrix.init)
                .mergeDuplicates()
                .flatMap(ChartPoint.fromIntMatrix)

            let series = RawPointData(
                from: yearAgo,
                to: today.addingDay(),
                points: points
            )

            data = series.chartData(for: StatPeriod.components)

        } catch {
            print(error.localizedDescription)
            data = nil
        }
    }
}

extension StatPeriod {

    /// A set of calendar components used for date calculations.
    fileprivate static var components: Set<Calendar.Component> {
        Set(StatPeriod.allCases.map(\.pointComponent))
    }
}
