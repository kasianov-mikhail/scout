//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import SwiftUI

class MetricsProvider<T: ChartNumeric>: ObservableObject, Provider {
    @Published var result: ProviderResult<[GridMatrix<T>]>?

    private let telemetry: Telemetry.Export

    init(telemetry: Telemetry.Export) {
        self.telemetry = telemetry
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
            format: "date >= %@ AND date < %@ AND category == %@",
            dateRange.lowerBound as NSDate,
            dateRange.upperBound as NSDate,
            telemetry.rawValue
        )

        return CKQuery(
            recordType: T.recordName,
            predicate: predicate
        )
    }
}
