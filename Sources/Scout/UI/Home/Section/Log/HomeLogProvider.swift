//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@MainActor
class HomeLogProvider: ObservableObject, Provider {
    typealias Output = ([GridMatrix<Int>], [GridMatrix<Double>])

    @Published var period: Period {
        didSet {
            UserDefaults.standard.set(period.rawValue, forKey: "scout_home_log_period")
        }
    }

    @Published private var results: [Period: ProviderResult<Output>] = [:]

    init() {
        self.period = UserDefaults.standard.string(forKey: "scout_home_log_period").flatMap(Period.init) ?? .today
    }

    var result: ProviderResult<Output>? {
        get { results[period] }
        set { results[period] = newValue }
    }

    func fetch(in database: DatabaseReader) async throws -> Output {
        async let intMatrices = matrices(
            of: Int.self,
            in: period.initialRange,
            from: database
        )

        async let doubleMatrices = matrices(
            of: Double.self,
            in: period.initialRange,
            from: database
        )

        return try await (
            intMatrices.filter { !lifecycleNames.contains($0.name) },
            doubleMatrices
        )
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
    let query = RecordQuery(
        recordType: GridMatrix<T>.self,
        filters: (range.lowerBound.startOfWeek..<range.upperBound).dateFilters
    )
    let matrices: [GridMatrix<T>] = try await database.readAll(matching: query)
    return matrices.mergeDuplicates()
}

extension HomeLogProvider {
    static func sample(for period: Period) -> Output {
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
