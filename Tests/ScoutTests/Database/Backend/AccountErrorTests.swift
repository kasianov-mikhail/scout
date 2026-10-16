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
}
