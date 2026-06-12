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
/// and identifiers are rendered through ``ExportFormat``.
///
struct TimelineExport {
    let rail: Rail

    /// The exported document, or `nil` when the rail has no installs.
    var text: String? {
        guard rail.installs.count > 0 else {
            return nil
        }

        var lines = [title, summary]

        for install in rail.installs {
            lines.append("")
            lines.append(header(for: install.install))

            for launch in install.launches {
                lines.append("")
                lines.append(header(for: launch.launch))

                for session in launch.sessions {
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
            return "# Scout Timeline — Device \(ExportFormat.shortID(deviceID))"
        }
        return "# Scout Timeline"
    }

    private var summary: String {
        let launches = rail.installs.flatMap(\.launches)
        let sessions = launches.flatMap(\.sessions)
        let events = sessions.flatMap(\.events).filter { $0.date != nil }
        let crashes = sessions.flatMap(\.crashes).filter { $0.date != nil }

        var parts = [
            ExportFormat.counted(rail.installs.count, "install", "installs"),
            ExportFormat.counted(launches.count, "launch", "launches"),
            ExportFormat.counted(sessions.count, "session", "sessions"),
            ExportFormat.counted(events.count, "event", "events"),
        ]
        if crashes.count > 0 {
            parts.append(ExportFormat.counted(crashes.count, "crash", "crashes"))
        }
        return parts.joined(separator: " · ")
    }

    private func header(for install: Install) -> String {
        var parts = ["## Install"]
        if let date = install.date {
            parts.append(ExportFormat.day(date))
        }
        if let id = install.installID {
            parts.append("(\(ExportFormat.shortID(id)))")
        }
        return parts.joined(separator: " ")
    }

    private func header(for launch: Launch) -> String {
        var parts = ["### Launch"]
        if let date = launch.startDate {
            parts.append(ExportFormat.minute(date))
        }
        if let id = launch.launchID {
            parts.append("(\(ExportFormat.shortID(id)))")
        }
        return parts.joined(separator: " ")
    }

    private func header(for session: Session) -> String {
        var parts = ["#### Session"]
        if let start = session.startDate {
            parts.append(ExportFormat.range(from: start, to: session.endDate))
        }
        if let id = session.sessionID {
            parts.append("(\(ExportFormat.shortID(id)))")
        }
        return parts.joined(separator: " ")
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
            .map { "- \(ExportFormat.timestamp($0.date))  \($0.label)" }
    }

    private func label(for crash: Crash) -> String {
        if let reason = crash.reason {
            return "⚠️ crash: \(crash.name) (\(reason))"
        }
        return "⚠️ crash: \(crash.name)"
    }
}
