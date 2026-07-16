//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct CachedQuery {
    let recordType: any RecordDecodable.Type
    let range: Range<Date>
    let frozenUpper: Date
    let fingerprint: String

    private let restFilters: [RecordQuery.Filter]

    init?(query: RecordQuery, scope: String, cutoff: Date) {
        guard query.sort.count == 0 else { return nil }
        guard cachedRecordTypes.contains(query.recordType.recordType) else { return nil }

        var lower: Date?
        var upper: Date?
        var rest: [RecordQuery.Filter] = []

        for filter in query.filters {
            if filter.field == "date", filter.op == .greaterThanOrEquals, case .date(let date) = filter.value,
                lower == nil
            {
                lower = date
            } else if filter.field == "date", filter.op == .lessThan, case .date(let date) = filter.value, upper == nil
            {
                upper = date
            } else if filter.field == "date" {
                return nil
            } else {
                rest.append(filter)
            }
        }

        guard let lower, let upper, lower < upper, lower < cutoff else { return nil }
        guard let fingerprint = Self.fingerprint(scope: scope, recordType: query.recordType.recordType, filters: rest)
        else {
            return nil
        }

        self.recordType = query.recordType
        self.range = lower..<upper
        self.frozenUpper = min(upper, cutoff)
        self.fingerprint = fingerprint
        self.restFilters = rest
    }

    func query(in range: Range<Date>) -> RecordQuery {
        RecordQuery(recordType: recordType, filters: range.dateFilters + restFilters)
    }

    private static func fingerprint(scope: String, recordType: String, filters: [RecordQuery.Filter]) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        var parts: [String] = []
        for filter in filters {
            guard let data = try? encoder.encode(filter), let part = String(data: data, encoding: .utf8) else {
                return nil
            }
            parts.append(part)
        }
        return ([scope, recordType] + parts.sorted()).joined(separator: "|")
    }
}

private let cachedRecordTypes: Set<String> = [
    GridMatrix<Int>.recordType,
    GridMatrix<Double>.recordType,
]
