//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout

struct AccountErrorTests {
    @Test("Account status titles the alert by status") func account() {
        let error = Backend.AccountError.noAccount

        #expect(error.title == "Not Signed In to iCloud")
        #expect(error.localizedDescription == "Sign in to iCloud to sync data.")
    }

    @Test("Other failures fall back to a generic title and keep the underlying description") func failure() {
        let error = Backend.AccountError.failure(URLError(.notConnectedToInternet))

        #expect(error.title == "iCloud Error")
        #expect(error.localizedDescription == URLError(.notConnectedToInternet).localizedDescription)
    }

    @Test("An account error passes through and any other error becomes a failure") func wrapping() {
        #expect(Backend.AccountError(Backend.AccountError.noAccount).title == "Not Signed In to iCloud")
        #expect(Backend.AccountError(URLError(.notConnectedToInternet)).title == "iCloud Error")
    }

    @Test("Account issues leave the backend read-only and failures make it unreachable") func status() {
        #expect(Backend.AccountError.noAccount.status == .readOnly)
        #expect(Backend.AccountError.restricted.status == .readOnly)
        #expect(Backend.AccountError.temporarilyUnavailable.status == .readOnly)
        #expect(Backend.AccountError.couldNotDetermine.status == .unreachable)
        #expect(Backend.AccountError.failure(URLError(.notConnectedToInternet)).status == .unreachable)
    }
}
