//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension HTTPDatabaseError: TransientFailure {
    var isTransient: Bool {
        switch status {
        case 401, 403, 404, 408, 429, 500...:
            true
        default:
            false
        }
    }
}

extension URLError: TransientFailure {
    package var isTransient: Bool {
        true
    }
}
