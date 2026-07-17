//
// Copyright 2025 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

struct EventQuery: Equatable {
    private static let allLevels = Set(EventLevel.allCases)

    var levels = EventQuery.allLevels
    var text = ""
    var name = ""
    var sessionID: UUID?
    var deviceID: UUID?
    var dates: Range<Date>?

    func buildFilters() -> [RecordQuery.Filter] {
        var filters: [RecordQuery.Filter] = []

        if levels != EventQuery.allLevels {
            filters.append(RecordQuery.Filter(field: "level", op: .in, value: .strings(levels.map(\.rawValue))))
        }
        if !text.isEmpty {
            filters.append(RecordQuery.Filter(field: "name", op: .beginsWith, value: .string(text)))
        }
        if !name.isEmpty {
            filters.append(RecordQuery.Filter(field: "name", op: .equals, value: .string(name)))
        }
        if let sessionID {
            filters.append(RecordQuery.Filter(field: "session_id", op: .equals, value: .string(sessionID.uuidString)))
        }
        if let deviceID {
            filters.append(RecordQuery.Filter(field: "device_id", op: .equals, value: .string(deviceID.uuidString)))
        }
        if let dates {
            filters.append(contentsOf: dates.dateFilters)
        }

        return filters
    }
}
