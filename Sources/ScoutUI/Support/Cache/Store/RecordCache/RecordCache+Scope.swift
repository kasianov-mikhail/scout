//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation

extension RecordCache {
    func removeAll(scope: String) {
        guard let context else {
            return
        }

        let predicate = NSPredicate(format: "fingerprint BEGINSWITH %@", "\(scope)|")

        do {
            try context.performAndWait {
                try context.deleteAll(entity: "CachedSpan", predicate: predicate)
                try context.deleteAll(entity: "CachedRecord", predicate: predicate)
            }
        } catch {
            print("Failed to clear the record cache for \(scope): \(error)")
        }
    }
}
