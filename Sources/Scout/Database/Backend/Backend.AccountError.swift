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
                "iCloud Account Unavailable"
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
                "You're not signed in to iCloud. Sign in from Settings, then try again. Events stay on the devices and upload later."
            case .restricted:
                "iCloud is restricted on this device by parental controls or a device policy. Check it in Settings, then try again. Events stay on the devices and upload later."
            case .temporarilyUnavailable:
                "Your Apple Account is signed in, but iCloud can't use it right now. Check it in Settings, then try again. Events stay on the devices and upload later."
            case .couldNotDetermine:
                "Scout couldn't determine your iCloud account status. Check your connection, then try again. Events stay on the devices and upload later."
            case .failure(let error):
                error.localizedDescription
            }
        }
    }
}
