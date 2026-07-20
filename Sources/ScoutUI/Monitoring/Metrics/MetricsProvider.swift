//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

class MetricsProvider<T: ChartNumeric>: ObservableObject, Provider {
    @Published var result: ProviderResult<[MetricSeries]>?

    private let telemetry: Telemetry.Export

    init(telemetry: Telemetry.Export) {
        self.telemetry = telemetry
    }

    func fetch(in database: DatabaseReader) async throws -> [MetricSeries] {
        try await database.metricSeries(
            T.self,
            category: telemetry.rawValue,
            reduce: telemetry == .meter ? .last : .sum,
            in: Calendar.utc.defaultRange
        )
    }
}
