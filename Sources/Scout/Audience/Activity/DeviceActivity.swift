//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

package struct DeviceActivity: Equatable, Sendable {
    package let deviceID: String
    package let model: String?
    package let osVersion: String?
    package let lastSeen: Date
    package let sessions: Int
    package let crashes: Int

    package init(deviceID: String, model: String?, osVersion: String?, lastSeen: Date, sessions: Int, crashes: Int) {
        self.deviceID = deviceID
        self.model = model
        self.osVersion = osVersion
        self.lastSeen = lastSeen
        self.sessions = sessions
        self.crashes = crashes
    }
}
