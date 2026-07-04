//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@MainActor
class HomeLogProvider: ObservableObject {
    typealias Output = ([GridMatrix<Int>], [GridMatrix<Double>])

    @Published private var results: [Period: ProviderResult<Output>] = [:]

    func result(for period: Period) -> ProviderResult<Output>? {
        results[period]
    }

    func fetchAgain(for period: Period, in database: DatabaseReader) async {
        results[period] = nil
        await fetchIfNeeded(for: period, in: database)
    }

    func fetchIfNeeded(for period: Period, in database: DatabaseReader) async {
        guard results[period] == nil else {
            return
        }
        do {
            results[period] = .success(try await fetch(for: period, in: database))
        } catch is CancellationError {
            // A cancelled task (e.g. the view was recreated) leaves the result untouched so it retries.
        } catch {
            results[period] = .failure(error)
        }
    }

    private func fetch(for period: Period, in database: DatabaseReader) async throws -> Output {
        async let intMatrices = matrices(of: Int.self, in: period.initialRange, from: database)
        async let doubleMatrices = matrices(of: Double.self, in: period.initialRange, from: database)

        return try await (intMatrices.filter { !lifecycleNames.contains($0.name) }, doubleMatrices)
    }
}

extension HomeLogProvider {
    static func fixture(periods: [Period] = Period.allCases) -> HomeLogProvider {
        let provider = HomeLogProvider()
        for period in periods {
            provider.results[period] = .success(sampleOutput(for: period))
        }
        return provider
    }

    private static func sampleOutput(for period: Period) -> Output {
        let date = period.initialRange.lowerBound
        let intMatrices = [
            GridMatrix(date: date, name: EventObject.recordType, cells: [GridCell(row: 1, column: 0, value: 48)]),
            GridMatrix(date: date, name: CrashObject.recordType, cells: [GridCell(row: 1, column: 1, value: 3)]),
            GridMatrix(
                date: date,
                name: "api_calls",
                category: Telemetry.Export.counter.rawValue,
                cells: [GridCell(row: 1, column: 2, value: 140)]
            )
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

private let lifecycleNames: Set = [
    DeviceObject.recordType,
    InstallObject.recordType,
    LaunchObject.recordType,
    SessionObject.recordType,
    VersionObject.recordType,
]

private func matrices<T: MetricScalar>(of type: T.Type, in range: Range<Date>, from database: DatabaseReader) async throws -> [GridMatrix<T>] {
    // Matrices are dated at the start of their week, so the query widens the
    // lower bound to the week start to catch the matrix holding the range's first days.
    let query = RecordQuery(
        recordType: GridMatrix<T>.self,
        filters: (range.lowerBound.startOfWeek..<range.upperBound).dateFilters
    )
    let matrices: [GridMatrix<T>] = try await database.readAll(matching: query)
    return matrices.mergeDuplicates()
}
