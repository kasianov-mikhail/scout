//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

@MainActor
class StatProvider: ObservableObject {
    let eventName: String
    let periods: [Period]

    @Published var data: ChartData<Period>?

    init(eventName: String, periods: [Period]) {
        self.eventName = eventName
        self.periods = periods
    }
}

extension StatProvider: Provider {
    func fetch(in database: DatabaseController) async {
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
