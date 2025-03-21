//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CloudKit
import Logging

@MainActor var container: CKContainer?

@MainActor public func setup(container: CKContainer) throws {
    Scout.container = container
    LoggingSystem.bootstrap(CKLogHandler.init)
    try NotificationListener.activity.setup()
}
