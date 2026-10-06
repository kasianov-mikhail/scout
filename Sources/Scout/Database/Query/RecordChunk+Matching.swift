//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension RecordChunk {
    package init(records: [Record], query: RecordQuery, limit: Int) {
        self = Self.page(of: records.filter { query.matches($0) }.sorted(by: query.ordering), limit: limit, after: 0)
    }

    private static func page(of matches: [Record], limit: Int, after offset: Int) -> RecordChunk {
        let page = matches.dropFirst(offset).prefix(limit)
        let next = offset + page.count

        return RecordChunk(
            records: Array(page),
            cursor: next < matches.count
                ? RecordCursor { _ in Self.page(of: matches, limit: limit, after: next) }
                : nil
        )
    }
}

extension RecordQuery {
    fileprivate var ordering: (Record, Record) -> Bool {
        { lhs, rhs in
            for key in effectiveSort {
                let order = RecordValue.compare(lhs.fields[key.field], rhs.fields[key.field])
                guard order != .orderedSame else {
                    continue
                }
                return key.ascending ? order == .orderedAscending : order == .orderedDescending
            }
            return false
        }
    }
}

extension RecordValue {
    fileprivate static func compare(_ lhs: RecordValue?, _ rhs: RecordValue?) -> ComparisonResult {
        switch (lhs, rhs) {
        case (nil, nil):
            return .orderedSame
        case (nil, _):
            return .orderedAscending
        case (_, nil):
            return .orderedDescending
        case (.string(let lhs), .string(let rhs)):
            return lhs < rhs ? .orderedAscending : lhs == rhs ? .orderedSame : .orderedDescending
        case (let lhs?, let rhs?):
            guard let lhs = lhs.value, let rhs = rhs.value else {
                return .orderedSame
            }
            return lhs < rhs ? .orderedAscending : lhs == rhs ? .orderedSame : .orderedDescending
        }
    }
}
