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
        var lines = ["# Scout Hang — \(hang.name)"]

        if let date = hang.date {
            lines.append(ExportFormat.timestamp(date))
        }
        lines.append("")
        lines.append("Duration: \(hang.durationText)")
        if let reason = hang.reason {
            lines.append("")
            lines.append("Reason: \(reason)")
        }
        if hang.stackTrace.count > 0 {
            lines.append("")
            lines.append("## Stack Trace")
            lines.append("```")
            lines.append(contentsOf: hang.stackTrace)
            lines.append("```")
        }

        return lines.joined(separator: "\n")
    }
}

struct HangGroupExport {
    let group: ReliabilityGroup<Hang>

    var text: String {
        var lines = [title, group.exportSummary]

        if let seen = group.exportSeenLine {
            lines.append(seen)
        }
        lines.append("")
        lines.append("Max duration: \(group.durationText)")
        if let frame = group.exportTopFrame {
            lines.append("")
            lines.append("Top frame: \(frame)")
        }

        let rows = group.records.compactMap(row)
        if rows.count > 0 {
            lines.append("")
            lines.append("## Occurrences")
            lines.append(contentsOf: rows)
        }

        return lines.joined(separator: "\n")
    }

    private var title: String {
        "# Scout Hang Issue — \(group.name)"
    }

    private func row(for hang: Hang) -> String? {
        guard let date = hang.date else { return nil }

        var ids: [String] = []
        if let deviceID = hang.deviceID {
            ids.append("device \(ExportFormat.shortID(deviceID))")
        }
        if let sessionID = hang.sessionID {
            ids.append("session \(ExportFormat.shortID(sessionID))")
        }

        let row = "- \(ExportFormat.timestamp(date))  \(hang.durationText)"
        return ids.count > 0 ? "\(row)  (\(ids.joined(separator: ", ")))" : row
    }
}
