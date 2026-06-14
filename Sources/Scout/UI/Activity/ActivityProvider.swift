//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

class ActivityProvider: QueryProvider<ActivityMatrix> {
    init() {
        super.init {
            RecordQuery(
                recordType: PeriodCell<Int>.recordType,
                filters: Calendar.utc.defaultRange.dateFilters + [
                    RecordFilter(field: "name", op: .equals, value: .string("ActiveUser"))
                ]
            )
        }
    }

    /// A Scout server aggregates DAU/WAU/MAU natively, so read its flat series
    /// and rebuild the chart's matrices from it.
    ///
    /// CloudKit backends still answer the `PeriodMatrix` query the initializer
    /// builds.
    ///
    override func fetch(in database: AppDatabase) async throws -> [ActivityMatrix] {
        guard let server = database as? ActiveUsersReading else {
            return try await super.fetch(in: database)
        }
        let series = try await server.activeUsers(in: Calendar.utc.defaultRange)
        return ActivityMatrix.from(series: series)
    }
}
