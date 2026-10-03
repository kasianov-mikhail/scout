//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Backend {
    package enum AccountError: LocalizedError {
        case noAccount
        case restricted
        case couldNotDetermine
        case temporarilyUnavailable

        package var errorDescription: String? {
            switch self {
            case .noAccount:
                "Sign in to iCloud to sync data."
            case .restricted:
                "iCloud access is restricted by parental controls or a device policy."
            case .temporarilyUnavailable:
                "Your iCloud account is temporarily unavailable. Try again later."
            case .couldNotDetermine:
                "Couldn't determine your iCloud account status. Check your connection and try again."
            }
        }
    }
}
