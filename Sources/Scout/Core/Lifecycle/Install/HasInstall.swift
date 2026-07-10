//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol HasInstall {
    var install: InstallObject? { get }
}

extension HasInstall {
    var installID: UUID? {
        install?.installID
    }

    var deviceID: UUID? {
        install?.deviceID
    }
}
