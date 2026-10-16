//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Testing

@testable import Scout
@testable import Support

struct BackendTests {
    @Test("A passing access check probes as reachable") func reachable() async {
        let backend = makeBackend(id: "backend", checkAccess: {})

        #expect(await backend.probeStatus?() == .reachable)
    }

    @Test("A failing access check probes as the status of its error") func failing() async {
        let backend = makeBackend(id: "backend", checkAccess: checkNoAccount)

        #expect(await backend.probeStatus?() == .readOnly)
    }

    @Test("A backend without an access check has no probe") func missing() {
        let backend = makeBackend(id: "backend")

        #expect(backend.probeStatus == nil)
    }
}

private func checkNoAccount() async throws(Backend.AccountError) {
    throw .noAccount
}
