//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Scout

enum ICloudIssue {
    case account(Backend.AccountError)
    case failure(any Error)

    var title: String {
        switch self {
        case .account(.noAccount):
            "Not Signed In to iCloud"
        case .account(.restricted):
            "iCloud Restricted"
        case .account(.temporarilyUnavailable):
            "iCloud Temporarily Unavailable"
        case .account(.couldNotDetermine):
            "iCloud Status Unknown"
        case .failure:
            "iCloud Error"
        }
    }

    var message: String {
        switch self {
        case .account(let error):
            error.localizedDescription
        case .failure(let error):
            error.localizedDescription
        }
    }
}
