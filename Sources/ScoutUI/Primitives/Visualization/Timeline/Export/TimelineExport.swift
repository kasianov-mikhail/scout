//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
//

import Foundation
import Scout

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

        var lines: [ExportLine] = [.heading(level: 1, title), .text(summary)]

        for install in rail.installs {
            lines.append(.blank)
            lines.append(header(for: install.install))

            for launch in install.launches {
                lines.append(.blank)
                lines.append(header(for: launch.launch))

                for session in launch.sessions {
                    lines.append(.blank)
                    lines.append(header(for: session.session))
                    lines.append(contentsOf: rows(for: session))
                }
            }
        }

        return lines.text
    }
}

extension TimelineExport {
    private var title: String {
        if let deviceID = rail.device.deviceID {
            return "Scout Timeline — Device \(ExportFormat.shortID(deviceID))"
        }
        return "Scout Timeline"
    }

    private var summary: String {
        let launches = rail.installs.flatMap(\.launches)
        let sessions = launches.flatMap(\.sessions)
        let events = sessions.flatMap(\.events).filter { $0.date != nil }
        let crashes = sessions.flatMap(\.crashes).filter { $0.date != nil }

        var parts = [
            ExportFormat.counted(rail.installs.count, .install),
            ExportFormat.counted(launches.count, .launch),
            ExportFormat.counted(sessions.count, .session),
            ExportFormat.counted(events.count, .event),
        ]
        if crashes.count > 0 {
            parts.append(ExportFormat.counted(crashes.count, .crash))
        }
        return parts.joined(separator: " · ")
    }

    private func header(level: Int, word: String, date: String?, id: UUID?) -> ExportLine {
        var parts = [word]
        if let date {
            parts.append(date)
        }
        if let id {
            parts.append("(\(ExportFormat.shortID(id)))")
        }
        return .heading(level: level, parts.joined(separator: " "))
    }

    private func header(for install: Install) -> ExportLine {
        header(level: 2, word: "Install", date: install.date.map(ExportFormat.day), id: install.installID)
    }

    private func header(for launch: Launch) -> ExportLine {
        header(level: 3, word: "Launch", date: launch.startDate.map(ExportFormat.minute), id: launch.launchID)
    }

    private func header(for session: Session) -> ExportLine {
        header(
            level: 4,
            word: "Session",
            date: session.startDate.map { ExportFormat.range(from: $0, to: session.endDate) },
            id: session.sessionID
        )
    }
}

extension TimelineExport {
    private func rows(for session: SessionRoot) -> [ExportLine] {
        let events = session.events.compactMap { event in
            event.date.map { (date: $0, label: event.name) }
        }
        let crashes = session.crashes.compactMap { crash in
            crash.date.map { (date: $0, label: label(for: crash)) }
        }
        return (events + crashes)
            .sorted { $0.date < $1.date }
            .map { .bullet("\(ExportFormat.timestamp($0.date))  \($0.label)") }
    }

    private func label(for crash: Crash) -> String {
        if let reason = crash.reason {
            return "⚠️ crash: \(crash.name) (\(reason))"
        }
        return "⚠️ crash: \(crash.name)"
    }
}
