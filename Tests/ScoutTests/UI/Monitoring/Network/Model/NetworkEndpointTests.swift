//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Testing

@testable import Scout

@Suite("NetworkEndpoint")
struct NetworkEndpointTests {
    @Test("Splits a known HTTP verb prefix into method and path")
    func methodAndPath() {
        let endpoint = makeEndpoint(name: "GET /v1/events")

        #expect(endpoint.method == "GET")
        #expect(endpoint.path == "/v1/events")
    }

    @Test("Keeps the full name as path when no verb prefix is present")
    func plainName() {
        let endpoint = makeEndpoint(name: "sync_pipeline")

        #expect(endpoint.method == nil)
        #expect(endpoint.path == "sync_pipeline")
    }

    @Test("Rejects unknown and lowercase verbs")
    func unknownVerbs() {
        #expect(makeEndpoint(name: "FETCH /x").method == nil)
        #expect(makeEndpoint(name: "get /x").method == nil)
    }

    private func makeEndpoint(name: String) -> NetworkEndpoint {
        NetworkEndpoint(name: name, requests: 0, successRate: nil, p99: nil)
    }
}
