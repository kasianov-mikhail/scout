//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

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
