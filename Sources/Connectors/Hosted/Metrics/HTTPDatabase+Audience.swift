//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension HTTPDatabase: AudienceReader {
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        let endpoint = URL(string: "api/v1/metrics/active-users?" + range.queryParameters, relativeTo: url)

        return try await get(
            from: endpoint,
            reason: "Malformed metrics URL",
            as: ActivityResponse.self
        )
        .series
    }

    private struct ActivityResponse: Decodable {
        let series: [ActivityPoint]
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        let endpoint = URL(string: "api/v1/metrics/retention?" + range.queryParameters, relativeTo: url)

        let response = try await get(
            from: endpoint,
            reason: "Malformed metrics URL",
            as: RetentionResponse.self
        )

        return response.cohorts.map {
            RetentionCohort(
                id: Date(millisecondsSince1970: $0.date),
                size: $0.size,
                retention: $0.retained.rates(of: $0.size),
                segments: []
            )
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

extension [Int?] {
    fileprivate func rates(of size: Int) -> [Double?] {
        map { count in
            guard let count, size > 0 else {
                return nil
            }
            return Double(count) / Double(size)
        }
    }
}
