//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension HTTPDatabaseError: TransientFailure {
    package var isTransient: Bool {
        status == 429 || status >= 500
    }
}

extension URLError: TransientFailure {
    package var isTransient: Bool {
        true
    }
}
