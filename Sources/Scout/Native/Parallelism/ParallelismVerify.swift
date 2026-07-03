//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import CloudKit
import Foundation
import ScoutDB

extension CKContainer {
    @MainActor func verifyParallelismIfDue() {
        #if DEBUG
            let parallelismCheckInterval: TimeInterval = 7 * 24 * 60 * 60
            let key = "scout.parallelismCheckDate"
            let lastCheck = UserDefaults.standard.object(forKey: key) as? Date

            if let lastCheck, Date().timeIntervalSince(lastCheck) < parallelismCheckInterval {
                return
            }

            Task {
                await verifyScoutParallelism(container: self)
                UserDefaults.standard.set(Date(), forKey: key)
            }
        #endif
    }
}

/// Runs ScoutDB's parallelism check with Scout's own traffic drained, so the
/// measurement is not polluted by concurrent Scout requests.
@discardableResult func verifyScoutParallelism(container: CKContainer) async -> Bool {
    await requestLimiter.withAllSlots {
        await verifyParallelismBenchmark(container: container, recordType: EventObject.recordType)
    }
}
