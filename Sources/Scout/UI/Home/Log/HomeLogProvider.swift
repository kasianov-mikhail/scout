//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// Fetches the stat matrices backing the Home Log counters in one pass:
/// every `DateIntMatrix` and `DateDoubleMatrix` of the default range,
/// so switching periods needs no further requests.
///
class HomeLogProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<HomeLogSummary>?

    func fetch(in database: AppDatabase) async throws -> HomeLogSummary {
        let intQuery = query(for: Int.recordType)
        let doubleQuery = query(for: Double.recordType)

        async let intRecords = database.readAll(matching: intQuery, fields: nil)
        async let doubleRecords = database.readAll(matching: doubleQuery, fields: nil)

        return HomeLogSummary(
            intMatrices: try await intRecords.map { try GridMatrix<Int>(record: $0) }.mergeDuplicates(),
            doubleMatrices: try await doubleRecords.map { try GridMatrix<Double>(record: $0) }.mergeDuplicates()
        )
    }

    private func query(for recordType: String) -> RecordQuery {
        RecordQuery(recordType: recordType, filters: Calendar.utc.defaultRange.dateFilters)
    }
}
