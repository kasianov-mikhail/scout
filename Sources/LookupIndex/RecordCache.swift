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
    private var context: ModelContext

    init(location: RecordCacheLocation = RecordCacheLocation()) throws {
        self.location = location
        context = ModelContext(try Self.container(at: location.storeURL, in: location))
    }

    var size: Int64 {
        var descriptor = FetchDescriptor<CachedRecord>()
        descriptor.propertiesToFetch = [\.size]

        let rows = (try? context.fetch(descriptor)) ?? []
        return rows.reduce(0) { $0 + Int64($1.size) }
    }

    func removeAll() {
        do {
            context = ModelContext(try Self.container(at: location.nextStoreURL, in: location))
            location.retire()
            return
        } catch {
            print("Failed to open the next record cache store, so the current one is emptied in place: \(error)")
        }

        try? context.delete(model: CachedRecord.self)
        try? context.delete(model: CachedSpan.self)
        try? context.save()
    }

    func coveredRange(for fingerprint: String) -> Range<Date>? {
        let predicate = #Predicate<CachedSpan> { $0.fingerprint == fingerprint }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1

        guard let span = try? context.fetch(descriptor).first, span.lowerDate < span.upperDate else {
            return nil
        }
        return span.lowerDate..<span.upperDate
    }

    func records(for fingerprint: String, in range: Range<Date>) -> [Record]? {
        let descriptor = FetchDescriptor(
            predicate: CachedRecord.predicate(fingerprint: fingerprint, in: range),
            sortBy: [SortDescriptor(\.date)]
        )
        guard let entries = try? context.fetch(descriptor) else {
            return nil
        }

        let decoder = JSONDecoder()
        let records = entries.compactMap {
            try? decoder.decode(Record.self, from: $0.payload)
        }
        guard records.count == entries.count else {
            return nil
        }
        return records
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
            guard let payload = try? encoder.encode(record) else {
                return
            }
            entries.append(CachedRecord(fingerprint: fingerprint, date: date, payload: payload))
        }

        let predicate = #Predicate<CachedSpan> { $0.fingerprint == fingerprint }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1

        if let span = try? context.fetch(descriptor).first, span.lowerDate <= range.lowerBound, range.lowerBound <= span.upperDate {
            try? context.delete(
                model: CachedRecord.self,
                where: CachedRecord.predicate(fingerprint: fingerprint, in: range)
            )
            span.upperDate = max(span.upperDate, range.upperBound)
        } else {
            try? context.delete(
                model: CachedRecord.self,
                where: CachedRecord.predicate(fingerprint: fingerprint)
            )
            try? context.delete(
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
        try? context.save()
    }

    func lookupRecord(for fingerprint: String) -> Record? {
        var descriptor = FetchDescriptor(predicate: CachedRecord.predicate(fingerprint: fingerprint))
        descriptor.fetchLimit = 1

        guard let entry = try? context.fetch(descriptor).first else {
            return nil
        }
        return try? JSONDecoder().decode(Record.self, from: entry.payload)
    }

    func storeLookup(_ record: Record, for fingerprint: String) {
        guard let payload = try? JSONEncoder().encode(record) else {
            return
        }

        try? context.delete(
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

        try? context.save()
    }
}

@available(iOS 18, macOS 15, *)
extension RecordCache: RecordCaching {}
