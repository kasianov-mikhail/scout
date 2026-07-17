//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

protocol HasLaunch {
    var launch: LaunchEntry? { get }
}

extension HasLaunch {
    var launchID: UUID? {
        launch?.launchID
    }

    var installID: UUID? {
        launch?.installID
    }

    var deviceID: UUID? {
        launch?.deviceID
    }
}
