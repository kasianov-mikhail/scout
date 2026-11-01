//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import HostedConnector
@testable import Scout

@Suite("Hosted backend identity")
struct HostedBackendTests {
    @Test(
        "A trailing slash does not change the backend identity",
        arguments: [
            "https://api.scout.app",
            "https://api.scout.app/collect",
            "http://localhost:8080",
        ])
    func trailingSlash(url: String) {
        let plain = Backend.server(url: URL(string: url)!, apiKey: "key")
        let slashed = Backend.server(url: URL(string: url + "/")!, apiKey: "key")

        #expect(plain.id == slashed.id)
        #expect(plain.displayName == slashed.displayName)
    }

    @Test("The identity drops the slash and lowercases the scheme and host")
    func normalizedIdentity() {
        let backend = Backend.server(url: URL(string: "HTTPS://API.Scout.App/")!, apiKey: nil)

        #expect(backend.id == "https://api.scout.app")
    }
}
