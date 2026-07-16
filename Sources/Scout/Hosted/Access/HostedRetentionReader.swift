//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension HTTPDatabase: RetentionReader {
    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        let from = range.lowerBound.millisecondsSince1970
        let to = range.upperBound.millisecondsSince1970

        guard let endpoint = URL(string: "api/v1/metrics/retention?from=\(from)&to=\(to)", relativeTo: url) else {
            throw HTTPDatabaseError(status: 0, reason: "Malformed metrics URL")
        }

        let data = try await perform(request(for: endpoint, method: "GET"))
        return try JSONDecoder().decode(RetentionResponse.self, from: data).cohorts.map {
            RetentionCohort(date: $0.date, size: $0.size, retained: $0.retained)
        }
    }

    private struct RetentionResponse: Decodable {
        let cohorts: [Cohort]

        struct Cohort: Decodable {
            let date: Int64
            let size: Int
            let retained: [Int?]
        }
    }
}
