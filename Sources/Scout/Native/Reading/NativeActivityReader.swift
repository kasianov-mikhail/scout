//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit

extension CKDatabase: ActivityReader {}

extension ActivityReader {
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        let query = RecordQuery(
            recordType: PeriodMatrix.self,
            filters: range.dateFilters
        )

        let matrices = try await readAll(
            matching: query,
            fields: nil
        )
        .map(PeriodMatrix.init)

        return ActivityPoint.points(from: matrices)
    }
}
