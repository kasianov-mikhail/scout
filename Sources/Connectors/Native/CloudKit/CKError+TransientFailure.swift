//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Scout

extension CKError: TransientFailure {
    package var isTransient: Bool {
        switch code {
        case .networkUnavailable, .networkFailure, .serviceUnavailable, .requestRateLimited, .zoneBusy,
            .accountTemporarilyUnavailable, .operationCancelled:
            true
        default:
            retryAfterSeconds != nil
        }
    }
}
