//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

class ResetMarkerProvider: ObservableObject, Provider {
    @Published var result: ProviderResult<[Date]>?

    private let name: String
    private let isEnabled: Bool

    init(name: String, isEnabled: Bool) {
        self.name = name
        self.isEnabled = isEnabled
    }

    func fetch(in database: DatabaseReader) async throws -> [Date] {
        guard isEnabled else { return [] }

        let series = try await database.metricSeries(
            Int.self,
            category: ResetMarker.category,
            in: Calendar.utc.defaultRange
        )

        return
            series
            .filter { $0.name == name }
            .flatMap(\.points)
            .map { Date(millisecondsSince1970: $0.date) }
            .sorted()
    }

    func dates(in range: Range<Date>) -> [Date] {
        guard case .success(let dates)? = result else { return [] }
        return dates.filter(range.contains)
    }
}
