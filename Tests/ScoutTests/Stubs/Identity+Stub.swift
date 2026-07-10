//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

@testable import Scout

extension Identity {
    // A shared fixture so object stubs and the monitors under test agree on the
    // install/launch/device/session identifiers.
    static let stub = Identity(install: UUID(), launch: UUID(), device: UUID(), session: Protected(UUID()))
}
