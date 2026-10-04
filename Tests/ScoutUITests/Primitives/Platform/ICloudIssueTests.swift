//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Testing

@testable import Scout
@testable import ScoutUI

struct ICloudIssueTests {
    @Test("Account issue titles the alert by status and reuses the error description") func account() {
        let issue = ICloudIssue.account(.noAccount)

        #expect(issue.title == "Not Signed In to iCloud")
        #expect(issue.message == Backend.AccountError.noAccount.errorDescription)
    }

    @Test("Other failures fall back to a generic title") func failure() {
        let issue = ICloudIssue.failure(URLError(.notConnectedToInternet))

        #expect(issue.title == "iCloud Error")
        #expect(issue.message == URLError(.notConnectedToInternet).localizedDescription)
    }
}
