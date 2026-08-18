//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

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

extension HTTPDatabase {
    func ping() async throws {
        let query = RecordQuery(
            recordType: Event.self,
            filters: [RecordQuery.Filter(field: "name", op: .equals, value: .string(""))]
        )
        _ = try await read(matching: query, fields: nil, limit: 1)
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
    func send<Reply: Decodable>(_ body: some Encodable, to path: String, into reply: Reply.Type) async throws -> Reply {
        guard let endpoint = URL(string: path, relativeTo: url) else {
            throw HTTPDatabaseError(status: 0, reason: "Malformed endpoint URL")
        }

        var request = request(for: endpoint, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let data = try await perform(request)
        return try JSONDecoder().decode(Reply.self, from: data)
    }

    func perform(_ request: URLRequest) async throws -> Data {
        try await requireBackgroundTime()
        let (data, response) = try await session.data(for: request)
        try check(response, data: data)
        return data
    }

    func request(for endpoint: URL, method: String) -> URLRequest {
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
