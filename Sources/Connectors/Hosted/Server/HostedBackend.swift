//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension Backend {
    public static func server(url: URL, apiKey: String?) -> Backend {
        let database = HTTPDatabase(url: url, apiKey: apiKey)

        return Backend(
            id: url.absoluteString,
            database: database,
            displayName: url.host ?? url.absoluteString,
            engine: .server(
                .init(
                    endpoint: url.hostWithPort ?? url.absoluteString,
                    hasAPIKey: apiKey != nil,
                    isSecure: url.scheme?.lowercased() == "https"
                )
            ),
            checkAccess: { try await database.access.check(ping: database.ping) },
            probeAccess: database.ping
        )
    }
}

extension URL {
    fileprivate var hostWithPort: String? {
        guard let host else { return nil }
        return port.map { "\(host):\($0)" } ?? host
    }
}
