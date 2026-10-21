//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

@MainActor
final class MetricsProvider<T: ChartNumeric>: ObservableObject, SeriesProvider {
    @Published var result: ProviderResult<[MetricSeries]>?

    private let name: String?
    private let telemetry: Telemetry.Export

    init(name: String?, telemetry: Telemetry.Export) {
        self.name = name
        self.telemetry = telemetry
    }

    func fetch(in database: SeriesReader) async throws -> [MetricSeries] {
        try await database.metricSeries(
            T.self,
            name: name,
            category: telemetry.rawValue,
            reduce: telemetry == .meter ? .last : .sum,
            in: Date().trailingYear
        )
    }
}
