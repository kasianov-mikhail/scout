//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation

/// Builds the Markdown document exported by the timeline's share and copy actions.
///
/// The document mirrors the rail hierarchy: a title with the device ID and a
/// summary of counts, then a section per install, launch, and session, with
/// events and crashes as chronological list rows under their session. Dates
/// are rendered in UTC — headers in a human-readable form, rows as ISO 8601
/// timestamps — so the text reads well and stays machine-parseable.
///
struct TimelineExport {
    let rail: Rail

    /// The exported document, or `nil` when the rail has no installs.
    var text: String? {
        guard rail.installs.count > 0 else {
            return nil
        }

        var lines = [title, summary]

        for install in rail.installs.sorted(byDate: \.install.date) {
            lines.append("")
            lines.append(header(for: install.install))

            for launch in install.launches.sorted(byDate: \.launch.startDate) {
                lines.append("")
                lines.append(header(for: launch.launch))

                for session in launch.sessions.sorted(byDate: \.session.startDate) {
                    lines.append("")
                    lines.append(header(for: session.session))
                    lines.append(contentsOf: rows(for: session))
                }
            }
        }

        return lines.joined(separator: "\n")
    }
}

// MARK: - Sections

extension TimelineExport {
    private var title: String {
        if let deviceID = rail.device.deviceID {
            return "# Scout Timeline — Device \(shortID(deviceID))"
        }
        return "# Scout Timeline"
    }

    private var summary: String {
        let launches = rail.installs.flatMap(\.launches)
        let sessions = launches.flatMap(\.sessions)
        let events = sessions.flatMap(\.events).filter { $0.date != nil }
        let crashes = sessions.flatMap(\.crashes).filter { $0.date != nil }

        var parts = [
            counted(rail.installs.count, "install", "installs"),
            counted(launches.count, "launch", "launches"),
            counted(sessions.count, "session", "sessions"),
            counted(events.count, "event", "events"),
        ]
        if crashes.count > 0 {
            parts.append(counted(crashes.count, "crash", "crashes"))
        }
        return parts.joined(separator: " · ")
    }

    private func header(for install: Install) -> String {
        var parts = ["## Install"]
        if let date = install.date {
            parts.append(Self.day.format(date))
        }
        if let id = install.installID {
            parts.append("(\(shortID(id)))")
        }
        return parts.joined(separator: " ")
    }

    private func header(for launch: Launch) -> String {
        var parts = ["### Launch"]
        if let date = launch.startDate {
            parts.append(Self.minute(date))
        }
        if let id = launch.launchID {
            parts.append("(\(shortID(id)))")
        }
        return parts.joined(separator: " ")
    }

    private func header(for session: Session) -> String {
        var parts = ["#### Session"]
        if let start = session.startDate {
            parts.append(range(from: start, to: session.endDate))
        }
        if let id = session.sessionID {
            parts.append("(\(shortID(id)))")
        }
        return parts.joined(separator: " ")
    }

    /// Formats a session range, repeating the date in the end bound only when
    /// the session spans more than one day.
    ///
    private func range(from start: Date, to end: Date?) -> String {
        guard let end else {
            return Self.minute(start)
        }
        let sameDay = Self.day.format(start) == Self.day.format(end)
        let suffix = sameDay ? Self.time.format(end) : Self.minute(end)
        return "\(Self.minute(start))–\(suffix)"
    }
}

// MARK: - Rows

extension TimelineExport {
    private func rows(for session: SessionRoot) -> [String] {
        let events = session.events.compactMap { event in
            event.date.map { (date: $0, label: event.name) }
        }
        let crashes = session.crashes.compactMap { crash in
            crash.date.map { (date: $0, label: label(for: crash)) }
        }
        return (events + crashes)
            .sorted { $0.date < $1.date }
            .map { "- \(Self.timestamp.format($0.date))  \($0.label)" }
    }

    private func label(for crash: Crash) -> String {
        if let reason = crash.reason {
            return "⚠️ crash: \(crash.name) (\(reason))"
        }
        return "⚠️ crash: \(crash.name)"
    }
}

// MARK: - Formatting

extension TimelineExport {
    private func shortID(_ id: UUID) -> String {
        String(id.uuidString.lowercased().prefix(8))
    }

    private func counted(_ count: Int, _ singular: String, _ plural: String) -> String {
        "\(count) \(count == 1 ? singular : plural)"
    }

    private static let timestamp = Date.ISO8601FormatStyle()
    private static let day = utcStyle("\(year: .padded(4))-\(month: .twoDigits)-\(day: .twoDigits)")
    private static let time = utcStyle("\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)")

    private static func minute(_ date: Date) -> String {
        "\(day.format(date)) \(time.format(date))"
    }

    private static func utcStyle(_ format: Date.FormatString) -> Date.VerbatimFormatStyle {
        Date.VerbatimFormatStyle(format: format, timeZone: .gmt, calendar: Calendar(identifier: .gregorian))
    }
}
