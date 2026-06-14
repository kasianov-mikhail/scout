//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension HTTPDatabase: BackendDatabase {}

/// A Scout server (`scout-server`).
///
/// Aggregation happens in SQL on the server, so only raw records are uploaded
/// — including raw metric values, which on CloudKit exist solely as matrices.
///
public struct ServerBackend: Backend {
    let url: URL
    let apiKey: String?

    public init(url: URL, apiKey: String? = nil) {
        self.url = url
        self.apiKey = apiKey
    }
}

extension ServerBackend: BackendResolving {
    var resolved: ResolvedBackend {
        let url = url
        let apiKey = apiKey
        return ResolvedBackend(
            id: url.absoluteString,
            database: HTTPDatabase(url: url, apiKey: apiKey),
            needsClientAggregation: false,
            acceptsRawMetrics: true,
            checkAvailability: {},
            displayName: url.host ?? url.absoluteString,
            displayHost: url.absoluteString,
            probeStatus: {
                do {
                    try await HTTPDatabase(url: url, apiKey: apiKey).ping()
                    return .reachable
                } catch {
                    return .unreachable
                }
            },
            onSetup: {
                // An API key over a non-HTTPS connection — and every uploaded
                // record — would travel in cleartext, readable by any observer.
                if apiKey != nil, url.scheme?.lowercased() != "https" {
                    print("[Scout] The API key for '\(url)' will be sent over a non-HTTPS connection in cleartext. Use an https:// URL.")
                }
            }
        )
    }
}
