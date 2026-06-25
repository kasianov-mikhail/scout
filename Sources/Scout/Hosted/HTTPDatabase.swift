//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

private let maxBatchSize = 400
let defaultRecordPageSize = 400

struct HTTPDatabase: Sendable {
    let url: URL
    let apiKey: String?
    let session: URLSession

    init(url: URL, apiKey: String?, session: URLSession = .shared) {
        self.url = url.absoluteString.hasSuffix("/") ? url : URL(string: url.absoluteString + "/") ?? url
        self.apiKey = apiKey
        self.session = session
    }
}

extension HTTPDatabase: RecordWriter {
    func write(record: Record) async throws {
        try await write(records: [record])
    }

    func write(records: [Record]) async throws {
        for chunk in records.chunked(into: maxBatchSize) {
            let request = HTTPWriteRequest(records: chunk.map(HTTPRecord.init))
            try await send(request, to: "api/v1/records", into: HTTPWriteAck.self)
        }
    }

    private struct HTTPWriteAck: Decodable {
        let saved: Int
    }
}

extension HTTPDatabase: RecordReader {
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
}

extension HTTPDatabase: RecordLocator {
    func lookup(recordName: String, fields: [String]?) async throws -> Record {
        let allowed = CharacterSet.urlPathAllowed.subtracting(CharacterSet(charactersIn: "/"))
        let name = recordName.addingPercentEncoding(withAllowedCharacters: allowed) ?? recordName

        var path = "api/v1/records/\(name)"
        if let fields {
            let list = fields.joined(separator: ",")
            path += "?fields=\(list.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? list)"
        }

        guard let endpoint = URL(string: path, relativeTo: url) else {
            throw HTTPDatabaseError(status: 0, reason: "Malformed record URL")
        }

        let data = try await perform(request(for: endpoint, method: "GET"))
        return try JSONDecoder().decode(HTTPRecord.self, from: data).toRecord()
    }
}

extension HTTPDatabase {
    func ping() async throws {
        let query = RecordQuery(
            recordType: Event.self,
            filters: [RecordQuery.Filter(field: "name", op: .equals, value: .string(""))]
        )
        _ = try await read(matching: query, fields: nil, limit: 1)
    }
}

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

extension HTTPDatabase: MetricSeriesReader {
    func metricSeries(category: String, values: String, in range: Range<Date>) async throws -> [MetricSeries] {
        let from = range.lowerBound.millisecondsSince1970
        let to = range.upperBound.millisecondsSince1970
        let category = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? category

        let path = "api/v1/metrics/series?category=\(category)&values=\(values)&bucket=hour&dense=false&from=\(from)&to=\(to)"
        guard let endpoint = URL(string: path, relativeTo: url) else {
            throw HTTPDatabaseError(status: 0, reason: "Malformed metrics URL")
        }

        let data = try await perform(request(for: endpoint, method: "GET"))
        return try JSONDecoder().decode(MetricSeriesResponse.self, from: data).series
    }

    private struct MetricSeriesResponse: Decodable {
        let series: [MetricSeries]
    }
}

struct HTTPDatabaseError: LocalizedError {
    let status: Int
    let reason: String?

    var errorDescription: String? {
        "Scout server returned \(status)\(reason.map { ": \($0)" } ?? "")"
    }
}

extension HTTPDatabase {
    @discardableResult
    private func send<Body: Encodable, Reply: Decodable>(_ body: Body, to path: String, into reply: Reply.Type) async throws -> Reply {
        guard let endpoint = URL(string: path, relativeTo: url) else {
            throw HTTPDatabaseError(status: 0, reason: "Malformed endpoint URL")
        }

        var request = request(for: endpoint, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let data = try await perform(request)
        return try JSONDecoder().decode(Reply.self, from: data)
    }

    private func perform(_ request: URLRequest) async throws -> Data {
        try await requireBackgroundTime()
        let (data, response) = try await session.data(for: request)
        try check(response, data: data)
        return data
    }

    private func request(for endpoint: URL, method: String) -> URLRequest {
        var request = URLRequest(url: endpoint)
        request.httpMethod = method
        request.timeoutInterval = 10
        if let apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        }
        return request
    }

    private func check(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            return
        }
        guard (200..<300).contains(http.statusCode) else {
            let reason = try? JSONDecoder().decode(HTTPErrorBody.self, from: data).reason
            throw HTTPDatabaseError(status: http.statusCode, reason: reason)
        }
    }

    private struct HTTPErrorBody: Decodable {
        let reason: String?
    }
}
