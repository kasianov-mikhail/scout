//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension HTTPDatabase: DatabaseReader {
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        try await read(matching: query, fields: fields, limit: defaultRecordPageSize)
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        try await run(query: HTTPQuery(query: query, fields: fields, limit: limit))
    }

    private func run(query: HTTPQuery) async throws -> RecordChunk {
        let response = try await send(query, to: "api/v1/records/query", into: HTTPQueryResponse.self)
        return RecordChunk(
            records: response.records.map { $0.toRecord() },
            cursor: response.cursor.map { token in
                RecordCursor { _ in
                    var next = HTTPQuery()
                    next.cursor = token
                    return try await self.run(query: next)
                }
            }
        )
    }

    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        let endpoint = recordEndpoint(recordName: recordName, fields: fields)
        return try await get(from: endpoint, reason: "Malformed record URL", as: HTTPRecord.self).toRecord()
    }

    private func get<T: Decodable>(from endpoint: URL?, reason: String, as type: T.Type) async throws -> T {
        guard let endpoint else {
            throw HTTPDatabaseError(status: 0, reason: reason)
        }
        let data = try await perform(request(for: endpoint, method: "GET"))
        return try JSONDecoder().decode(T.self, from: data)
    }

    func recordEndpoint(recordName: String, fields: [String]?) -> URL? {
        let allowed = CharacterSet.urlPathAllowed.subtracting(CharacterSet(charactersIn: "/"))
        let name = recordName.addingPercentEncoding(withAllowedCharacters: allowed) ?? recordName

        var path = "api/v1/records/\(name)"
        if let fields {
            path += "?fields=\(Self.encode(fields.joined(separator: ",")))"
        }
        return URL(string: path, relativeTo: url)
    }

    func series(matching query: SeriesQuery) async throws -> [MetricSeries] {
        try await get(from: seriesEndpoint(for: query), reason: "Malformed metrics URL", as: MetricSeriesResponse.self)
            .series
    }

    func seriesEndpoint(for query: SeriesQuery) -> URL? {
        var params = [
            "bucket=\(query.bucket.rawValue)",
            "from=\(query.range.lowerBound.millisecondsSince1970)",
            "to=\(query.range.upperBound.millisecondsSince1970)",
        ]
        if let name = query.name {
            params.append("name=\(Self.encode(name))")
        }
        if let category = query.category {
            params.append("category=\(Self.encode(category))")
        }
        if let values = query.values {
            params.append("values=\(Self.encode(values.rawValue))")
        }
        if let source = query.source {
            params.append("source=\(source.rawValue)")
        }
        if query.byVersion {
            params.append("by=version")
        }

        return URL(string: "api/v1/metrics/series?" + params.joined(separator: "&"), relativeTo: url)
    }

    private static let queryAllowed = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&=+?/"))

    private static func encode(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: queryAllowed) ?? value
    }

    private struct MetricSeriesResponse: Decodable {
        let series: [MetricSeries]
    }

    func activity(in range: Range<Date>) async throws -> [ActivityPoint] {
        let from = range.lowerBound.millisecondsSince1970
        let to = range.upperBound.millisecondsSince1970
        let endpoint = URL(string: "api/v1/metrics/active-users?from=\(from)&to=\(to)", relativeTo: url)
        return try await get(from: endpoint, reason: "Malformed metrics URL", as: ActivityResponse.self).series
    }

    private struct ActivityResponse: Decodable {
        let series: [ActivityPoint]
    }

    func retention(in range: Range<Date>) async throws -> [RetentionCohort] {
        let from = range.lowerBound.millisecondsSince1970
        let to = range.upperBound.millisecondsSince1970
        let endpoint = URL(string: "api/v1/metrics/retention?from=\(from)&to=\(to)", relativeTo: url)
        let response = try await get(from: endpoint, reason: "Malformed metrics URL", as: RetentionResponse.self)
        return response.cohorts.map {
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
