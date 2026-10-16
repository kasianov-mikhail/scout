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
        case failure(any Error)

        package init(_ error: any Error) {
            self = error as? AccountError ?? .failure(error)
        }

        package var title: String {
            switch self {
            case .noAccount:
                "Not Signed In to iCloud"
            case .restricted:
                "iCloud Restricted"
            case .temporarilyUnavailable:
                "iCloud Temporarily Unavailable"
            case .couldNotDetermine:
                "iCloud Status Unknown"
            case .failure:
                "iCloud Error"
            }
        }

        var status: Status {
            switch self {
            case .noAccount, .restricted, .temporarilyUnavailable:
                .readOnly
            case .couldNotDetermine, .failure:
                .unreachable
            }
        }

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
            case .failure(let error):
                error.localizedDescription
            }
        }
    }
}
