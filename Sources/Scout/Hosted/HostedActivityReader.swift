//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension HTTPDatabase: ActivityReader {
    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        let from = range.lowerBound.millisecondsSince1970
        let to = range.upperBound.millisecondsSince1970

        guard let endpoint = URL(string: "api/v1/metrics/active-users?from=\(from)&to=\(to)", relativeTo: url) else {
            throw HTTPDatabaseError(status: 0, reason: "Malformed metrics URL")
        }

        let data = try await perform(request(for: endpoint, method: "GET"))
        return try JSONDecoder().decode(ActivityResponse.self, from: data).series
    }

    private struct ActivityResponse: Decodable {
        let series: [ActivityPoint]
    }
}
