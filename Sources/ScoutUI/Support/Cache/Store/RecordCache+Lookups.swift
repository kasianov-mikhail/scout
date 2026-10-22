//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation
import Scout

extension RecordCache {
    func lookupRecord(for fingerprint: String) -> Record? {
        guard let context else {
            return nil
        }

        do {
            return try context.performAndWait {
                guard let entry = try context.fetch(CachedRecord.request(fingerprint: fingerprint)).first else {
                    return nil
                }
                return try JSONDecoder().decode(Record.self, from: entry.payload)
            }
        } catch {
            print("Failed to read a lookup record from the record cache: \(error)")
            return nil
        }
    }

    func storeLookup(_ record: Record, for fingerprint: String) {
        guard let context else {
            return
        }

        do {
            let payload = try JSONEncoder().encode(record)

            try context.performAndWait {
                try context.deleteAll(entity: "CachedRecord", predicate: CachedRecord.predicate(fingerprint: fingerprint))
                _ = CachedRecord(fingerprint: fingerprint, date: .distantPast, payload: payload, context: context)
                try context.save()
            }
        } catch {
            context.performAndWait { context.rollback() }
            print("Failed to store a lookup record in the record cache: \(error)")
        }
    }
}
