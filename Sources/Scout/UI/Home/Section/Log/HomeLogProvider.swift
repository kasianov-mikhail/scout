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

    @Published private var results: [Period: ProviderResult<Output>]

    init(results: [Period: ProviderResult<Output>] = [:]) {
        self.period = UserDefaults.standard.string(forKey: "scout_home_log_period").flatMap(Period.init) ?? .today
        self.results = results
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
