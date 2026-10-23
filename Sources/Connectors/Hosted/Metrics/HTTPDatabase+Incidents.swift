//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension HTTPDatabase: IncidentReader {
    func incidentIndex(recordType: String, in range: Range<Date>) async throws -> IncidentIndex? {
        let endpoint = URL(string: "api/v1/metrics/incidents?type=\(Self.encode(recordType))&" + range.queryParameters, relativeTo: url)

        let response = try await get(
            from: endpoint,
            reason: "Malformed metrics URL",
            as: IncidentsResponse.self
        )
        return try IncidentIndex(response: response)
    }

    fileprivate struct IncidentsResponse: Decodable {
        let tallies: [Tally]
        let unkeyed: Span?

        struct Tally: Decodable {
            let fingerprint: String
            let name: String
            let count: Int
            let firstHour: Int64
        }

        struct Span: Decodable {
            let from: Int64
            let to: Int64
        }
    }
}

extension IncidentIndex {
    fileprivate init(response: HTTPDatabase.IncidentsResponse) throws {
        self.init(
            tallies: response.tallies.map(IncidentTally.init(tally:)),
            unkeyed: try response.unkeyed.map(Range.init(span:))
        )
    }
}

extension IncidentTally {
    fileprivate init(tally: HTTPDatabase.IncidentsResponse.Tally) {
        self.init(
            fingerprint: tally.fingerprint,
            name: tally.name,
            count: tally.count,
            firstHour: Date(millisecondsSince1970: tally.firstHour)
        )
    }
}

extension Range<Date> {
    fileprivate init(span: HTTPDatabase.IncidentsResponse.Span) throws {
        guard span.from <= span.to else {
            throw HTTPDatabaseError(status: 0, reason: "Malformed unkeyed incident range")
        }
        self = Date(millisecondsSince1970: span.from)..<Date(millisecondsSince1970: span.to)
    }
}
