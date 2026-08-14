//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout

@Suite("Server info setup warning")
struct SetupWarningTests {
    @Test("An API key over plain HTTP is called out")
    func plainHTTPWithKeyWarns() throws {
        let info = Backend.Engine.ServerInfo(endpoint: "localhost:8080", hasAPIKey: true, isSecure: false)
        let warning = try #require(info.setupWarning)

        #expect(warning.contains("localhost:8080"))
    }

    @Test("HTTPS carries the key safely")
    func secureTransportIsSilent() {
        let info = Backend.Engine.ServerInfo(endpoint: "api.scout.app", hasAPIKey: true, isSecure: true)

        #expect(info.setupWarning == nil)
    }

    @Test("A keyless connection has nothing to leak")
    func missingKeyIsSilent() {
        let info = Backend.Engine.ServerInfo(endpoint: "localhost:8080", hasAPIKey: false, isSecure: false)

        #expect(info.setupWarning == nil)
    }
}
