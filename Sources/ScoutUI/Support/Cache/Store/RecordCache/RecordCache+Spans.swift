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
    func coveredRange(for fingerprint: String) -> Range<Date>? {
        guard let context else {
            return nil
        }

        do {
            return try context.performAndWait {
                guard let span = try context.fetch(CachedSpan.request(fingerprint: fingerprint)).first else {
                    return nil
                }
                guard span.lowerDate < span.upperDate else {
                    return nil
                }
                return span.lowerDate..<span.upperDate
            }
        } catch {
            print("Failed to read the covered range of the record cache: \(error)")
            return nil
        }
    }

    func records(for fingerprint: String, in range: Range<Date>) -> [Record]? {
        guard let context else {
            return nil
        }

        let decoder = JSONDecoder()

        do {
            return try context.performAndWait {
                try context.fetch(CachedRecord.request(fingerprint: fingerprint, in: range)).map {
                    try decoder.decode(Record.self, from: $0.payload)
                }
            }
        } catch {
            print("Failed to read records from the record cache: \(error)")
            return nil
        }
    }
}
