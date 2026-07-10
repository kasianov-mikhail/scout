//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol HasSession {
    var session: SessionObject? { get }
}

extension HasSession {
    var sessionID: UUID? {
        session?.sessionID
    }

    var launchID: UUID? {
        session?.launchID
    }

    var installID: UUID? {
        session?.installID
    }

    var deviceID: UUID? {
        session?.deviceID
    }
}
