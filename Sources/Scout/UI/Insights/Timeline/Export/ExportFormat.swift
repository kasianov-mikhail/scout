//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

enum ExportFormat {
    /// An ISO 8601 timestamp, e.g. `2023-11-14T22:14:00Z`.
    static func timestamp(_ date: Date) -> String {
        Self.iso8601.format(date)
    }

    /// A calendar day, e.g. `2023-11-14`.
    static func day(_ date: Date) -> String {
        Self.dayStyle.format(date)
    }

    /// A time of day with minute precision, e.g. `22:14`.
    static func time(_ date: Date) -> String {
        Self.timeStyle.format(date)
    }

    /// A day and time with minute precision, e.g. `2023-11-14 22:14`.
    static func minute(_ date: Date) -> String {
        "\(day(date)) \(time(date))"
    }

    static func range(from start: Date, to end: Date?) -> String {
        guard let end else {
            return minute(start)
        }
        let sameDay = day(start) == day(end)
        let suffix = sameDay ? time(end) : minute(end)
        return "\(minute(start))–\(suffix)"
    }

    /// The first eight characters of the identifier, lowercased.
    static func shortID(_ id: UUID) -> String {
        String(id.uuidString.lowercased().prefix(8))
    }

    /// A count with its pluralized noun, e.g. `1 install` or `3 installs`.
    static func counted(_ count: Int, _ noun: Noun) -> String {
        "\(count) \(count == 1 ? noun.singular : noun.plural)"
    }
}

extension ExportFormat {
    /// A noun with its singular and plural forms, used by ``counted(_:_:)``.
    struct Noun {
        let singular: String
        let plural: String
    }
}

extension ExportFormat.Noun {
    static let backend = Self(singular: "backend", plural: "backends")
    static let crash = Self(singular: "crash", plural: "crashes")
    static let device = Self(singular: "device", plural: "devices")
    static let event = Self(singular: "event", plural: "events")
    static let install = Self(singular: "install", plural: "installs")
    static let item = Self(singular: "item", plural: "items")
    static let launch = Self(singular: "launch", plural: "launches")
    static let occurrence = Self(singular: "occurrence", plural: "occurrences")
    static let pair = Self(singular: "pair", plural: "pairs")
    static let request = Self(singular: "request", plural: "requests")
    static let session = Self(singular: "session", plural: "sessions")
}

extension ExportFormat {
    private static let iso8601 = Date.ISO8601FormatStyle()
    private static let dayStyle = utcStyle("\(year: .padded(4))-\(month: .twoDigits)-\(day: .twoDigits)")
    private static let timeStyle = utcStyle("\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)")

    private static func utcStyle(_ format: Date.FormatString) -> Date.VerbatimFormatStyle {
        Date.VerbatimFormatStyle(format: format, timeZone: .gmt, calendar: Calendar(identifier: .gregorian))
    }
}
