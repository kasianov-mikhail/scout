//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import CoreData
import Foundation
import Scout

actor RecordCache: CacheClearing {
    private let location: RecordCacheLocation
    private lazy var context = open()

    init(location: RecordCacheLocation) {
        self.location = location
    }

    var size: Int64 {
        guard let context else {
            return 0
        }

        do {
            let rows = try context.performAndWait {
                let total = NSExpressionDescription()
                total.name = "total"
                total.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "size")])
                total.expressionResultType = .integer64AttributeType

                let request = NSFetchRequest<NSDictionary>(entityName: "CachedRecord")
                request.resultType = .dictionaryResultType
                request.propertiesToFetch = [total]
                return try context.fetch(request)
            }
            return rows.first?["total"] as? Int64 ?? 0
        } catch {
            print("Failed to measure the record cache: \(error)")
            return 0
        }
    }

    func removeAll() {
        if let coordinator = context?.persistentStoreCoordinator {
            do {
                for store in coordinator.persistentStores {
                    try coordinator.remove(store)
                }
            } catch {
                print("Failed to close the record cache store: \(error)")
            }
        }
        location.destroyStore()
        context = open()
    }

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

    private func open() -> NSManagedObjectContext? {
        do {
            try location.prepare(model: Self.model)

            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: Self.model)
            _ = try coordinator.addPersistentStore(type: .sqlite, configuration: nil, at: location.storeURL)

            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.persistentStoreCoordinator = coordinator
            return context
        } catch {
            print("Failed to open the record cache store, so backends stay uncached until the next launch: \(error)")
            return nil
        }
    }
}
