//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout
import Testing

@testable import ScoutUI
@testable import Support

@MainActor
@Suite("AccountProvider")
struct AccountProviderTests {
    @Test("A missing iCloud account holds the dashboard back")
    func blocksWithoutAccount() async {
        let provider = AccountProvider()

        await provider.probe(makeBackend(id: "backend", checkAccess: { throw Backend.AccountError.noAccount }))

        #expect(provider.issue?.title == "Not Signed In to iCloud")
        #expect(provider.isResolved)
    }

    @Test("An available iCloud account opens the dashboard")
    func opensForAvailableAccount() async {
        let provider = AccountProvider()

        await provider.probe(makeBackend(id: "backend", checkAccess: {}))

        #expect(provider.issue == nil)
        #expect(provider.isResolved)
    }

    @Test("A backend without an access check opens the dashboard")
    func opensWithoutCheck() async {
        let provider = AccountProvider()

        await provider.probe(makeBackend(id: "backend"))

        #expect(provider.issue == nil)
        #expect(provider.isResolved)
    }

    @Test("A transport failure keeps the dashboard for its own error view")
    func keepsDashboardForFailure() async {
        let provider = AccountProvider()

        await provider.probe(makeBackend(id: "backend", checkAccess: { throw URLError(.notConnectedToInternet) }))

        #expect(provider.issue == nil)
        #expect(provider.isResolved)
    }

    @Test("A later probe clears the issue once the account becomes usable")
    func recovers() async {
        let provider = AccountProvider()

        await provider.probe(makeBackend(id: "backend", checkAccess: { throw Backend.AccountError.temporarilyUnavailable }))
        #expect(provider.issue?.title == "iCloud Account Unavailable")

        await provider.probe(makeBackend(id: "backend", checkAccess: {}))

        #expect(provider.issue == nil)
        #expect(provider.isResolved)
    }
}
