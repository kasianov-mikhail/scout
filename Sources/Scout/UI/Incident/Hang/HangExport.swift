//
// Copyright 2026 Mikhail Kasianov
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import Foundation

struct HangExport {
    let hang: Hang

    var text: String {
        var lines: [ExportLine] = [.heading(level: 1, "Scout Hang — \(hang.name)")]

        if let date = hang.date {
            lines.append(.text(ExportFormat.timestamp(date)))
        }
        lines.append(.blank)
        lines.append(.text("Duration: \(hang.durationText)"))
        if let reason = hang.reason {
            lines.append(.blank)
            lines.append(.text("Reason: \(reason)"))
        }
        if hang.stackTrace.count > 0 {
            lines.append(.blank)
            lines.append(.heading(level: 2, "Stack Trace"))
            lines.append(.code(hang.stackTrace))
        }

        return lines.text
    }
}

struct HangGroupExport {
    let group: IncidentGroup<Hang>

    var text: String {
        var lines: [ExportLine] = [.heading(level: 1, title), .text(group.exportSummary)]

        if let seen = group.exportSeenLine {
            lines.append(.text(seen))
        }
        lines.append(.blank)
        lines.append(.text("Max duration: \(group.durationText)"))
        if let frame = group.exportTopFrame {
            lines.append(.blank)
            lines.append(.text("Top frame: \(frame)"))
        }

        let rows = group.records.compactMap(row)
        if rows.count > 0 {
            lines.append(.blank)
            lines.append(.heading(level: 2, "Occurrences"))
            lines.append(contentsOf: rows)
        }

        return lines.text
    }

    private var title: String {
        "Scout Hang Issue — \(group.name)"
    }

    private func row(for hang: Hang) -> ExportLine? {
        guard let date = hang.date else { return nil }

        var ids: [String] = []
        if let deviceID = hang.deviceID {
            ids.append("device \(ExportFormat.shortID(deviceID))")
        }
        if let sessionID = hang.sessionID {
            ids.append("session \(ExportFormat.shortID(sessionID))")
        }

        let row = "\(ExportFormat.timestamp(date))  \(hang.durationText)"
        return .bullet(ids.count > 0 ? "\(row)  (\(ids.joined(separator: ", ")))" : row)
    }
}
