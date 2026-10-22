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
    func store(_ records: [Record], for fingerprint: String, covering range: Range<Date>) {
        guard let context else {
            return
        }

        let encoder = JSONEncoder()

        do {
            try context.performAndWait {
                for record in records {
                    guard case .date(let date)? = record.fields["date"] else {
                        context.rollback()
                        return
                    }
                    guard range.contains(date) else {
                        continue
                    }
                    _ = CachedRecord(fingerprint: fingerprint, date: date, payload: try encoder.encode(record), context: context)
                }

                if let span = try context.fetch(CachedSpan.request(fingerprint: fingerprint)).first, span.lowerDate <= range.lowerBound, range.lowerBound <= span.upperDate {
                    try context.deleteAll(entity: "CachedRecord", predicate: CachedRecord.predicate(fingerprint: fingerprint, in: range))
                    span.upperDate = max(span.upperDate, range.upperBound)
                } else {
                    try context.deleteAll(entity: "CachedRecord", predicate: CachedRecord.predicate(fingerprint: fingerprint))
                    try context.deleteAll(entity: "CachedSpan", predicate: CachedSpan.predicate(fingerprint: fingerprint))
                    _ = CachedSpan(fingerprint: fingerprint, lowerDate: range.lowerBound, upperDate: range.upperBound, context: context)
                }
                try context.save()
            }
        } catch {
            context.performAndWait { context.rollback() }
            print("Failed to store records in the record cache: \(error)")
        }
    }

    func replace(_ records: [Record], for fingerprint: String, covering range: Range<Date>) {
        guard let context else {
            return
        }

        let encoder = JSONEncoder()

        do {
            try context.performAndWait {
                try context.deleteAll(entity: "CachedRecord", predicate: CachedRecord.predicate(fingerprint: fingerprint))
                try context.deleteAll(entity: "CachedSpan", predicate: CachedSpan.predicate(fingerprint: fingerprint))

                for record in records {
                    guard case .date(let date)? = record.fields["date"] else {
                        throw CocoaError(.validationMissingMandatoryProperty)
                    }
                    guard range.contains(date) else {
                        throw CocoaError(.validationInvalidDate)
                    }
                    _ = CachedRecord(fingerprint: fingerprint, date: date, payload: try encoder.encode(record), context: context)
                }
                _ = CachedSpan(fingerprint: fingerprint, lowerDate: range.lowerBound, upperDate: range.upperBound, context: context)
                try context.save()
            }
        } catch {
            context.performAndWait { context.rollback() }
            print("Failed to replace records in the record cache: \(error)")
        }
    }
}
