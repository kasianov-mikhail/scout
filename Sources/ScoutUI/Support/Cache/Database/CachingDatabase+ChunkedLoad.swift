//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension CachingDatabase {
    func cached<Item: RecordCacheable>(name: String, range: Range<Date>, frozenUpper: Date, fetch: (Range<Date>) async throws -> [Item]) async throws -> [Item] {
        let fingerprint = [scope, name].joined(separator: "|")
        let cached = await cachedSpan(for: fingerprint, in: range.lowerBound..<frozenUpper)
        var lower = cached?.upper ?? range.lowerBound
        var items = cached?.records.compactMap(Item.init(record:)) ?? []

        while lower.addingWeek(chunkWeeks) < frozenUpper {
            let upper = lower.addingWeek(chunkWeeks)
            let chunk = try await fetch(lower..<upper)
            await cache.store(chunk.compactMap(\.record), for: fingerprint, covering: lower..<upper)
            items += chunk
            lower = upper
        }

        guard lower < range.upperBound else {
            return items
        }

        let tail = try await fetch(lower..<range.upperBound)

        if lower < frozenUpper {
            await cache.store(tail.compactMap(\.record), for: fingerprint, covering: lower..<frozenUpper)
        }

        return items + tail
    }
}

private let chunkWeeks = 13

protocol RecordCacheable {
    init?(record: Record)
    var record: Record? { get }
}

extension RetentionCohort: RecordCacheable {
    init?(record: Record) {
        let payload: Data? = record["payload"]

        guard let payload else {
            return nil
        }

        do {
            self = try JSONDecoder().decode(RetentionCohort.self, from: payload)
        } catch {
            print("Failed to decode a cached retention cohort: \(error)")
            return nil
        }
    }

    var record: Record? {
        do {
            var record = Record(recordType: "RetentionCohort", recordID: UUID().uuidString)
            record["date"] = id
            record["payload"] = try JSONEncoder().encode(self)
            return record
        } catch {
            print("Failed to encode a retention cohort for the cache: \(error)")
            return nil
        }
    }
}

extension ActivityPoint: RecordCacheable {
    init?(record: Record) {
        let date: Date? = record["date"]
        let dau: Int? = record["dau"]
        let wau: Int? = record["wau"]
        let mau: Int? = record["mau"]

        guard let date, let dau, let wau, let mau else {
            return nil
        }

        self.init(date: date.millisecondsSince1970, dau: dau, wau: wau, mau: mau)
    }

    var record: Record? {
        var record = Record(recordType: "ActivityPoint", recordID: UUID().uuidString)
        record["date"] = Date(millisecondsSince1970: date)
        record["dau"] = dau
        record["wau"] = wau
        record["mau"] = mau
        return record
    }
}
