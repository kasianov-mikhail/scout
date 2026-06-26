//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

class HomeLogProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<([GridMatrix<Int>], [GridMatrix<Double>])>?

    func fetch(in database: DatabaseReader) async throws -> ([GridMatrix<Int>], [GridMatrix<Double>]) {
        async let intMatrices = matrices(of: Int.self, in: database)
        async let doubleMatrices = matrices(of: Double.self, in: database)

        return try await (intMatrices.filter { !lifecycleNames.contains($0.name) }, doubleMatrices)
    }
}

private let lifecycleNames = [
    DeviceObject.recordType,
    InstallObject.recordType,
    LaunchObject.recordType,
    SessionObject.recordType,
    VersionObject.recordType,
]

private func matrices<T: MetricScalar>(of type: T.Type, in database: DatabaseReader) async throws -> [GridMatrix<T>] {
    let query = RecordQuery(
        recordType: GridMatrix<T>.self,
        filters: Calendar.utc.defaultRange.dateFilters
    )
    return
        try await database
        .readAll(matching: query, fields: nil)
        .map { try GridMatrix<T>(record: $0) }
        .mergeDuplicates()
}
