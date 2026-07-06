//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension HomeLogProvider {
    static func fixture(periods: [Period] = Period.allCases) -> HomeLogProvider {
        var results: [Period: ProviderResult<Output>] = [:]
        for period in periods {
            results[period] = .success(output(for: period))
        }
        return HomeLogProvider(results: results)
    }

    private static func output(for period: Period) -> Output {
        let date = period.initialRange.lowerBound
        let intMatrices = [
            GridMatrix(
                date: date,
                name: EventObject.recordType,
                cells: [GridCell(row: 1, column: 0, value: 48)]
            ),
            GridMatrix(
                date: date,
                name: CrashObject.recordType,
                cells: [GridCell(row: 1, column: 1, value: 3)]
            ),
            GridMatrix(
                date: date,
                name: "api_calls",
                category: Telemetry.Export.counter.rawValue,
                cells: [GridCell(row: 1, column: 2, value: 140)]
            ),
        ]
        let doubleMatrices = [
            GridMatrix(
                date: date,
                name: "cache_hit_rate",
                category: Telemetry.Export.floatingCounter.rawValue,
                cells: [GridCell(row: 1, column: 3, value: 91.5)]
            )
        ]
        return (intMatrices, doubleMatrices)
    }
}
