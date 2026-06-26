//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

/// Formats the dates, identifiers, and counts that appear in exported
/// timeline documents.
///
/// All dates are rendered in UTC — headers in a human-readable form, rows as
/// ISO 8601 timestamps — so the text reads well and stays machine-parseable.
///
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

    /// Formats a date range, repeating the date in the end bound only when
    /// the range spans more than one day.
    ///
    /// An open range renders as its start.
    ///
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
    static func counted(_ count: Int, _ singular: String, _ plural: String) -> String {
        "\(count) \(count == 1 ? singular : plural)"
    }
}

extension ExportFormat {
    private static let iso8601 = Date.ISO8601FormatStyle()
    private static let dayStyle = utcStyle("\(year: .padded(4))-\(month: .twoDigits)-\(day: .twoDigits)")
    private static let timeStyle = utcStyle("\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)")

    private static func utcStyle(_ format: Date.FormatString) -> Date.VerbatimFormatStyle {
        Date.VerbatimFormatStyle(format: format, timeZone: .gmt, calendar: Calendar(identifier: .gregorian))
    }
}
