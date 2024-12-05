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
            yearAgo as NSDate,
            eventName
        )
        return predicate
    }
}

// MARK: - Data Processing

extension [ChartPoint] {

    /// Converts the current data to a `ChartData` object.
    /// 
    /// This computed property processes the existing data and transforms it into a format
    /// suitable for chart representation. The resulting `ChartData` can then be used for
    /// rendering charts within the UI.
    ///
    var toChartData: ChartData {
        let components = StatPeriod.allCases.map(\.pointComponent)

        return Set(components).reduce(into: [:]) { dict, component in
            dict[component] = group(by: component)
        }
    }

    /// Groups chart points by the specified calendar component.
    ///
    /// - Parameter component: The calendar component to group by (e.g., .day, .month, .year).
    /// - Returns: An array of `ChartPoint` objects grouped by the specified calendar component.
    ///
    func group(by component: Calendar.Component) -> [ChartPoint] {
        var result: [ChartPoint] = []

        let today = Calendar(identifier: .iso8601).startOfDay(for: Date())
        let tomorrow = today.addingDay(1)

        var date = today.addingYear(-1).addingWeek(-1)

        while date < tomorrow {
            let next = date.adding(component)

            let count = filter { item in
                (date..<next).contains(item.date)
            }.reduce(0) {
                $0 + $1.count
            }

            result.append(ChartPoint(date: date, count: count))
            date = next
        }

        return result
    }
}
