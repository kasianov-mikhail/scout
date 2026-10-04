//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Scout

extension CKAccountStatus {
    func verify() throws(Backend.AccountError) {
        switch self {
        case .available:
            return
        case .noAccount:
            throw .noAccount
        case .restricted:
            throw .restricted
        case .temporarilyUnavailable:
            throw .temporarilyUnavailable
        case .couldNotDetermine:
            throw .couldNotDetermine
        @unknown default:
            throw .couldNotDetermine
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
