//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Scout

extension CKAccountStatus {
    var error: Backend.AccountError? {
        switch self {
        case .available:
            nil
        case .noAccount:
            .noAccount
        case .restricted:
            .restricted
        case .temporarilyUnavailable:
            .temporarilyUnavailable
        case .couldNotDetermine:
            .couldNotDetermine
        @unknown default:
            .couldNotDetermine
        }
    }

    var backendStatus: Backend.Status {
        switch self {
        case .available:
            .reachable
        case .noAccount, .restricted, .temporarilyUnavailable:
            .readOnly
        case .couldNotDetermine:
            .unreachable
        @unknown default:
            .unreachable
        }
    }
}
