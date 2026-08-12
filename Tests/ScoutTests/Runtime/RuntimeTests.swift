//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import Support

@Suite("Runtime")
struct RuntimeTests {
    @Test("A runtime without backends is off")
    func noBackendsIsDisabled() {
        let runtime = Runtime(backends: [], identity: .stub, sync: {})

        #expect(!runtime.isEnabled)
    }

    @Test("A runtime with a backend is on")
    func oneBackendIsEnabled() {
        let runtime = Runtime(backends: [makeBackend(id: "cloud")], identity: .stub, sync: {})

        #expect(runtime.isEnabled)
    }

    @Test("The runtime hands out the session its identity carries")
    func sessionComesFromIdentity() {
        let runtime = Runtime.stub

        #expect(runtime.session.current == Identity.stub.session.current)
    }
}
