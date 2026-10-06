//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

@MainActor
final class ResetMarkerProvider: ObservableObject, SeriesProvider {
    @Published var result: ProviderResult<[Date]>?

    private let name: String
    private let isEnabled: Bool

    init(name: String, isEnabled: Bool) {
        self.name = name
        self.isEnabled = isEnabled
    }

    func fetch(in database: SeriesReader) async throws -> [Date] {
        guard isEnabled else { return [] }

        let series = try await database.metricSeries(
            Int.self,
            category: ResetMarker.category,
            in: Date().trailingYear
        )

        return
            series
            .filter { $0.name == name }
            .flatMap(\.points)
            .map(\.date)
            .sorted()
    }

    func dates(in range: Range<Date>) -> [Date] {
        guard case .success(let dates)? = result else {
            return []
        }
        return dates.filter(range.contains)
    }
}
