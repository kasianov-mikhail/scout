//
// Copyright 2024 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

class StatProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<[GridMatrix<Int>]>?

    let eventName: String
    let periods: [Period]

    init(eventName: String, periods: [Period]) {
        self.eventName = eventName
        self.periods = periods
    }

    func fetch(in database: AppDatabase) async throws -> Output {
        try await database
            .readAll(matching: query, fields: nil)
            .map(GridMatrix.init)
            .mergeDuplicates()
    }

    private var query: CKQuery {
        let dateRange = Calendar.utc.defaultRange

        let predicate = NSPredicate(
            format: "date >= %@ AND name == %@",
            dateRange.lowerBound as NSDate,
            eventName
        )

        return CKQuery(
            recordType: "DateIntMatrix",
            predicate: predicate
        )
    }
}
