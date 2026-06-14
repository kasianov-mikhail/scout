//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CloudKit
import Foundation

/// How often debug builds re-validate `RequestLimiter.requestLimit` against CloudKit.
private let parallelismCheckInterval: TimeInterval = 7 * 24 * 60 * 60

/// In debug builds, re-runs `verifyCloudKitParallelism` once `parallelismCheckInterval`
/// has passed since the last check, so a change in CloudKit's server-side limits shows
/// up in the console during development instead of going unnoticed.
///
@MainActor func verifyParallelismIfDue(container: CKContainer) {
    #if DEBUG
        let key = "scout.parallelismCheckDate"
        let lastCheck = UserDefaults.standard.object(forKey: key) as? Date

        if let lastCheck, Date().timeIntervalSince(lastCheck) < parallelismCheckInterval {
            return
        }

        Task {
            await verifyCloudKitParallelism(container: container)
            UserDefaults.standard.set(Date(), forKey: key)
        }
    #endif
}
