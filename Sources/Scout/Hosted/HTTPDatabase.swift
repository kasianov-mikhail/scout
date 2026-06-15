//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

/// Maximum number of records per write request, matching the server's cap
/// on its side and CloudKit's modify limit on ours.
private let maxBatchSize = 400

/// A Scout server reachable over HTTP, exposed through the same record
/// surface as CloudKit so the rest of the package cannot tell them apart.
///
struct HTTPDatabase: Sendable {
    let url: URL
    let apiKey: String?
    let session: URLSession

    init(url: URL, apiKey: String?, session: URLSession = .shared) {
        // Relative endpoint resolution drops the last path component of a
        // base URL without a trailing slash, so normalize it here.
        self.url = url.absoluteString.hasSuffix("/") ? url : URL(string: url.absoluteString + "/") ?? url
        self.apiKey = apiKey
        self.session = session
    }
}

// MARK: - Writing

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

// MARK: - Reading

extension HTTPDatabase: RecordReader {
    func read(matching query: RecordQuery, fields: [String]?) async throws -> RecordChunk {
        try await read(matching: query, fields: fields, limit: defaultRecordPageSize)
    }

    func read(matching query: RecordQuery, fields: [String]?, limit: Int) async throws -> RecordChunk {
        try await run(query: HTTPQuery(query: query, fields: fields, limit: limit))
    }

    func readMore(from cursor: RecordCursor, fields: [String]?) async throws -> RecordChunk {
        guard case .server(let token) = cursor else {
            throw CursorMismatchError()
        }
        var query = HTTPQuery()
        query.cursor = token
        return try await run(query: query)
    }

    private func run(query: HTTPQuery) async throws -> RecordChunk {
        let response = try await send(query, to: "api/v1/records/query", into: HTTPQueryResponse.self)
        return RecordChunk(
            records: response.records.map(\.toRecord),
            cursor: response.cursor.map(RecordCursor.server)
        )
    }
}

// MARK: - Lookup

extension HTTPDatabase: RecordLookup {
    func lookup(id: RecordID, fields: [String]?) async throws -> Record {
        let allowed = CharacterSet.urlPathAllowed.subtracting(CharacterSet(charactersIn: "/"))
        let name = id.recordName.addingPercentEncoding(withAllowedCharacters: allowed) ?? id.recordName

        var path = "api/v1/records/\(name)"
        if let fields {
            let list = fields.joined(separator: ",")
            path += "?fields=\(list.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? list)"
        }

        guard let endpoint = URL(string: path, relativeTo: url) else {
            throw HTTPDatabaseError(status: 0, reason: "Malformed record URL")
        }

        let data = try await perform(request(for: endpoint, method: "GET"))
        return try JSONDecoder().decode(HTTPRecord.self, from: data).toRecord
    }
}

// MARK: - Reachability

extension HTTPDatabase {
    /// A lightweight reachability probe for the data-source status dots.
    ///
    /// The server contract has no dedicated health route, so this issues a
    /// bounded `records/query` that fails fast when the server is down or
    /// rejects the API key. It is deliberately kept apart from the sync
    /// pre-flight `checkAvailability`, which stays a no-op for servers so a
    /// single down server never blocks syncing the others.
    ///
    func ping() async throws {
        let query = RecordQuery(
            recordType: "Event",
            filters: [RecordFilter(field: "name", op: .equals, value: .string(""))]
        )
        _ = try await read(matching: query, fields: nil, limit: 1)
    }
}

// MARK: - Metrics

extension HTTPDatabase: ActiveUsersReading {
    /// Fetches the server's native DAU/WAU/MAU series over `range`.
    ///
    /// The server aggregates from raw `Session` records, so the client reads a
    /// finished series instead of rebuilding it from `PeriodMatrix` cells.
    ///
    func activeUsers(in range: Range<Date>) async throws -> [ActiveUserPoint] {
        let from = Int64((range.lowerBound.timeIntervalSince1970 * 1000).rounded())
        let to = Int64((range.upperBound.timeIntervalSince1970 * 1000).rounded())

        guard let endpoint = URL(string: "api/v1/metrics/active-users?from=\(from)&to=\(to)", relativeTo: url) else {
            throw HTTPDatabaseError(status: 0, reason: "Malformed metrics URL")
        }

        let data = try await perform(request(for: endpoint, method: "GET"))
        return try JSONDecoder().decode(ActiveUsersResponse.self, from: data).series
    }

    /// The server's native active-user series — the response of
    /// `GET /api/v1/metrics/active-users`.
    ///
    private struct ActiveUsersResponse: Decodable {
        let series: [ActiveUserPoint]
    }
}

extension HTTPDatabase: MetricSeriesReading {
    /// Fetches the server's flat per-name series for a telemetry `category`.
    ///
    /// Requests sparse hourly buckets so a year-long range stays as compact as
    /// the matrix it replaces; the metrics UI rebuilds the weekly grid the
    /// chart consumes from the result.
    ///
    func metricSeries(category: String, values: String, in range: Range<Date>) async throws -> [MetricSeries] {
        let from = Int64((range.lowerBound.timeIntervalSince1970 * 1000).rounded())
        let to = Int64((range.upperBound.timeIntervalSince1970 * 1000).rounded())
        let category = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? category

        let path = "api/v1/metrics/series?category=\(category)&values=\(values)&bucket=hour&dense=false&from=\(from)&to=\(to)"
        guard let endpoint = URL(string: path, relativeTo: url) else {
            throw HTTPDatabaseError(status: 0, reason: "Malformed metrics URL")
        }

        let data = try await perform(request(for: endpoint, method: "GET"))
        return try JSONDecoder().decode(MetricSeriesResponse.self, from: data).series
    }

    /// The server's grouped metric series — the response of
    /// `GET /api/v1/metrics/series`.
    ///
    private struct MetricSeriesResponse: Decodable {
        let series: [MetricSeries]
    }
}

// MARK: - Transport

/// A non-2xx response from a Scout server.
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

    /// Runs one request, gating on background time and validating the response.
    ///
    /// Every network call funnels through here so the background-time guard that
    /// protects CloudKit requests applies equally to hosted servers.
    ///
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
