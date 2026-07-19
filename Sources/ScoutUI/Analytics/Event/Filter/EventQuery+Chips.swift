//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation
import Scout

extension EventQuery {
    struct Chip: Identifiable, Equatable {
        enum Kind: Hashable {
            case levels
            case dates
            case session
            case device
        }

        let kind: Kind
        let label: String

        var id: Kind { kind }
    }

    var chips: [Chip] {
        var chips: [Chip] = []

        if levels != EventQuery.allLevels {
            let label = levels.sorted().map(\.description).joined(separator: ", ")
            chips.append(Chip(kind: .levels, label: label))
        }
        if let dates {
            chips.append(Chip(kind: .dates, label: dates.label(using: EventQuery.chipFormatter)))
        }
        if let sessionID {
            chips.append(Chip(kind: .session, label: "Session \(sessionID.shortText)"))
        }
        if let deviceID {
            chips.append(Chip(kind: .device, label: "Device \(deviceID.shortText)"))
        }

        return chips
    }

    mutating func remove(_ kind: Chip.Kind) {
        switch kind {
        case .levels:
            levels = EventQuery.allLevels
        case .dates:
            dates = nil
        case .session:
            sessionID = nil
        case .device:
            deviceID = nil
        }
    }

    private static let chipFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = Calendar.utc.timeZone
        formatter.dateFormat = "d MMM"
        return formatter
    }()
}

extension UUID {
    fileprivate var shortText: String {
        String(uuidString.prefix(8))
    }
}
