//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct HTTPDatabase: Sendable {
    let url: URL
    let apiKey: String?

    init(url: URL, apiKey: String?) {
        self.url = url.absoluteString.hasSuffix("/") ? url : URL(string: url.absoluteString + "/") ?? url
        self.apiKey = apiKey
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
    func send<Reply: Decodable>(_ body: some Encodable, to path: String, into reply: Reply.Type) async throws -> Reply {
        let data = try await post(body, to: path)
        return try JSONDecoder().decode(Reply.self, from: data)
    }

    func post(_ body: some Encodable, to path: String) async throws -> Data {
        guard let endpoint = URL(string: path, relativeTo: url) else {
            throw HTTPDatabaseError(status: 0, reason: "Malformed endpoint URL")
        }

        var request = request(for: endpoint, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        return try await perform(request)
    }

    func perform(_ request: URLRequest) async throws -> Data {
        try await requireBackgroundTime()
        let (data, response) = try await URLSession.shared.data(for: request)
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

extension HTTPDatabase {
    func get<T: Decodable>(from endpoint: URL?, reason: String, as type: T.Type) async throws -> T {
        guard let endpoint else {
            throw HTTPDatabaseError(status: 0, reason: reason)
        }
        let data = try await perform(request(for: endpoint, method: "GET"))
        return try JSONDecoder().decode(T.self, from: data)
    }

    private static let queryAllowed = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&=+?/"))

    static func encode(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: queryAllowed) ?? value
    }
}

extension Range<Date> {
    var queryParameters: String {
        "from=\(lowerBound.millisecondsSince1970)&to=\(upperBound.millisecondsSince1970)"
    }
}
