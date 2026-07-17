//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import SwiftData

@available(iOS 17, macOS 14, *)
protocol RecordCaching: Actor {
    func coveredRange(for fingerprint: String) -> Range<Date>?
    func records(for fingerprint: String, in range: Range<Date>) -> [Record]?
    func store(_ records: [Record], for fingerprint: String, covering range: Range<Date>)
    func lookupRecord(for fingerprint: String) -> Record?
    func storeLookup(_ record: Record, for fingerprint: String)
}

@available(iOS 17, macOS 14, *)
@ModelActor
actor RecordCache<Row: CacheRow> {
    func coveredRange(for fingerprint: String) -> Range<Date>? {
        guard let span = span(for: fingerprint), span.lowerDate < span.upperDate else { return nil }
        return span.lowerDate..<span.upperDate
    }

    func records(for fingerprint: String, in range: Range<Date>) -> [Record]? {
        let lower = range.lowerBound
        let upper = range.upperBound
        let predicate = #Predicate<Row> {
            $0.fingerprint == fingerprint && $0.date >= lower && $0.date < upper
        }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\Row.date)])
        guard let entries = try? modelContext.fetch(descriptor) else { return nil }

        let decoder = JSONDecoder()
        let records = entries.compactMap { try? decoder.decode(CachedRecordPayload.self, from: $0.payload).record }
        guard records.count == entries.count else { return nil }
        return records
    }

    func store(_ records: [Record], for fingerprint: String, covering range: Range<Date>) {
        let encoder = JSONEncoder()
        var entries: [Row] = []

        for record in records {
            guard case .date(let date)? = record.fields["date"] else { return }
            guard range.contains(date) else { continue }
            guard let payload = try? encoder.encode(CachedRecordPayload(record: record)) else { return }
            entries.append(Row(fingerprint: fingerprint, date: date, payload: payload))
        }

        if let span = span(for: fingerprint), span.lowerDate <= range.lowerBound, range.lowerBound <= span.upperDate {
            deleteRecords(for: fingerprint, in: range)
            span.upperDate = max(span.upperDate, range.upperBound)
        } else {
            deleteAll(for: fingerprint)
            modelContext.insert(
                CachedSpan(fingerprint: fingerprint, lowerDate: range.lowerBound, upperDate: range.upperBound))
        }

        for entry in entries {
            modelContext.insert(entry)
        }
        try? modelContext.save()
    }

    func lookupRecord(for fingerprint: String) -> Record? {
        let predicate = #Predicate<Row> { $0.fingerprint == fingerprint }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        guard let entry = try? modelContext.fetch(descriptor).first else { return nil }
        return try? JSONDecoder().decode(CachedRecordPayload.self, from: entry.payload).record
    }

    func storeLookup(_ record: Record, for fingerprint: String) {
        guard let payload = try? JSONEncoder().encode(CachedRecordPayload(record: record)) else { return }
        let predicate = #Predicate<Row> { $0.fingerprint == fingerprint }
        try? modelContext.delete(model: Row.self, where: predicate)
        modelContext.insert(Row(fingerprint: fingerprint, date: .distantPast, payload: payload))
        try? modelContext.save()
    }

    private func span(for fingerprint: String) -> CachedSpan? {
        let predicate = #Predicate<CachedSpan> { $0.fingerprint == fingerprint }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }

    private func deleteRecords(for fingerprint: String, in range: Range<Date>) {
        let lower = range.lowerBound
        let upper = range.upperBound
        let predicate = #Predicate<Row> {
            $0.fingerprint == fingerprint && $0.date >= lower && $0.date < upper
        }
        try? modelContext.delete(model: Row.self, where: predicate)
    }

    private func deleteAll(for fingerprint: String) {
        let recordPredicate = #Predicate<Row> { $0.fingerprint == fingerprint }
        try? modelContext.delete(model: Row.self, where: recordPredicate)

        let spanPredicate = #Predicate<CachedSpan> { $0.fingerprint == fingerprint }
        try? modelContext.delete(model: CachedSpan.self, where: spanPredicate)
    }
}

@available(iOS 17, macOS 14, *)
extension RecordCache: RecordCaching {}
