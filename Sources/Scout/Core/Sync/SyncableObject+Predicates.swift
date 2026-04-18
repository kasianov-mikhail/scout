//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension SyncableObject {
    static var stalePredicate: NSPredicate {
        NSPredicate(format: "endDate == nil AND launchID != %@", IDs.launch as CVarArg)
    }

    static var pendingPredicate: NSPredicate {
        NSPredicate(format: "isSynced == false AND syncAttempts <= %d", maxSyncAttempts)
    }
}
