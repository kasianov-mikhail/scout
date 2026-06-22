//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

extension Event {
    struct Query {
        private static let allLevels = Set(Level.allCases)

        var levels = Query.allLevels
        var text = ""
        var name = ""
        var dates: Range<Date>?

        func buildFilters() -> [RecordQuery.Filter] {
            var filters: [RecordQuery.Filter] = []

            if levels != Query.allLevels {
                filters.append(RecordQuery.Filter(field: "level", op: .in, value: .strings(levels.map(\.rawValue))))
            }
            if !text.isEmpty {
                filters.append(RecordQuery.Filter(field: "name", op: .beginsWith, value: .string(text)))
            }
            if !name.isEmpty {
                filters.append(RecordQuery.Filter(field: "name", op: .equals, value: .string(name)))
            }
            if let dates {
                filters.append(contentsOf: dates.dateFilters)
            }

            return filters
        }
    }
}
