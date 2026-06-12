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

        func buildPredicate() -> NSPredicate {
            var predicates: [NSPredicate] = []

            if levels != Query.allLevels {
                predicates.append(.init(format: "level IN %@", levels.map(\.rawValue)))
            }
            if !text.isEmpty {
                predicates.append(.init(format: "name BEGINSWITH %@", text))
            }
            if !name.isEmpty {
                predicates.append(.init(format: "name == %@", name))
            }
            if let dates {
                predicates.append(dates.datePredicate)
            }

            return NSCompoundPredicate(type: .and, subpredicates: predicates)
        }
    }
}
