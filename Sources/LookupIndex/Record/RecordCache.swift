//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout
import SwiftData

@available(iOS 18, macOS 15, *)
actor RecordCache {
    static let schema = Schema([CachedRecord.self, CachedSpan.self])

    private let location: RecordCacheLocation
    private var container: ModelContainer
    private lazy var context = ModelContext(container)

    init(location: RecordCacheLocation = RecordCacheLocation()) throws {
        self.location = location
        self.container = try Self.container(at: location.storeURL, in: location)
    }

    var size: Int64 {
        var descriptor = FetchDescriptor<CachedRecord>()
        descriptor.propertiesToFetch = [\.size]

        do {
            let rows = try context.fetch(descriptor)
            return rows.reduce(0) { $0 + Int64($1.size) }
        } catch {
            print("Failed to measure the record cache: \(error)")
            return 0
        }
    }

    func removeAll() {
        do {
            container = try Self.container(at: location.nextStoreURL, in: location)
            context = ModelContext(container)
            location.retire()
            return
        } catch {
            print("Failed to open the next record cache store, so the current one is emptied in place: \(error)")
        }

        do {
            try context.delete(model: CachedRecord.self)
            try context.delete(model: CachedSpan.self)
            try context.save()
        } catch {
            print("Failed to empty the record cache: \(error)")
        }
    }

    func coveredRange(for fingerprint: String) -> Range<Date>? {
        let predicate = #Predicate<CachedSpan> { $0.fingerprint == fingerprint }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1

        do {
            guard let span = try context.fetch(descriptor).first else {
                return nil
            }
            guard span.lowerDate < span.upperDate else {
                return nil
            }
            return span.lowerDate..<span.upperDate
        } catch {
            print("Failed to read the covered range of the record cache: \(error)")
            return nil
        }
    }

    func records(for fingerprint: String, in range: Range<Date>) -> [Record]? {
        let descriptor = FetchDescriptor(
            predicate: CachedRecord.predicate(fingerprint: fingerprint, in: range),
            sortBy: [SortDescriptor(\.date)]
        )
        let decoder = JSONDecoder()

        do {
            let entries = try context.fetch(descriptor)
            return try entries.map {
                try decoder.decode(Record.self, from: $0.payload)
            }
        } catch {
            print("Failed to read records from the record cache: \(error)")
            return nil
        }
    }

    func store(_ records: [Record], for fingerprint: String, covering range: Range<Date>) {
        let encoder = JSONEncoder()
        var entries: [CachedRecord] = []

        for record in records {
            guard case .date(let date)? = record.fields["date"] else {
                return
            }
            guard range.contains(date) else {
                continue
            }
            do {
                let payload = try encoder.encode(record)
                entries.append(CachedRecord(fingerprint: fingerprint, date: date, payload: payload))
            } catch {
                print("Failed to encode a record for the record cache: \(error)")
                return
            }
        }

        let predicate = #Predicate<CachedSpan> { $0.fingerprint == fingerprint }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1

        do {
            if let span = try context.fetch(descriptor).first, span.lowerDate <= range.lowerBound, range.lowerBound <= span.upperDate {
                try context.delete(
                    model: CachedRecord.self,
                    where: CachedRecord.predicate(fingerprint: fingerprint, in: range)
                )
                span.upperDate = max(span.upperDate, range.upperBound)
            } else {
                try context.delete(
                    model: CachedRecord.self,
                    where: CachedRecord.predicate(fingerprint: fingerprint)
                )
                try context.delete(
                    model: CachedSpan.self,
                    where: predicate
                )

                context.insert(
                    CachedSpan(
                        fingerprint: fingerprint,
                        lowerDate: range.lowerBound,
                        upperDate: range.upperBound
                    )
                )
            }

            for entry in entries {
                context.insert(entry)
            }
            try context.save()
        } catch {
            print("Failed to store records in the record cache: \(error)")
        }
    }

    func lookupRecord(for fingerprint: String) -> Record? {
        var descriptor = FetchDescriptor(predicate: CachedRecord.predicate(fingerprint: fingerprint))
        descriptor.fetchLimit = 1

        do {
            guard let entry = try context.fetch(descriptor).first else {
                return nil
            }
            return try JSONDecoder().decode(Record.self, from: entry.payload)
        } catch {
            print("Failed to read a lookup record from the record cache: \(error)")
            return nil
        }
    }

    func storeLookup(_ record: Record, for fingerprint: String) {
        do {
            let payload = try JSONEncoder().encode(record)

            try context.delete(
                model: CachedRecord.self,
                where: CachedRecord.predicate(fingerprint: fingerprint)
            )

            context.insert(
                CachedRecord(
                    fingerprint: fingerprint,
                    date: .distantPast,
                    payload: payload
                )
            )

            try context.save()
        } catch {
            print("Failed to store a lookup record in the record cache: \(error)")
        }
    }
}

@available(iOS 18, macOS 15, *)
extension RecordCache: DatabaseCaching {
    nonisolated func cached(_ database: any DatabaseReader, scope: String) -> any DatabaseReader {
        CachedDatabase(base: database, scope: scope, cache: self)
    }
}
